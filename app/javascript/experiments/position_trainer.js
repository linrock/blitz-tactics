import $ from 'jquery'
import Backbone from 'backbone'
import Chess from 'chess.js'

import StockfishEngine from '../workers/stockfish_engine'
import { uciToMove } from '../utils'

const SEARCH_DEPTH = 15
const START_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"


let getQueryParam = (param) => {
  let query = window.location.search.substring(1);
  let vars = query.split('&');
  for (let i = 0; i < vars.length; i++) {
    let pair = vars[i].split('=');
    if (decodeURIComponent(pair[0]) === param) {
      return decodeURIComponent(pair[1]);
    }
  }
}

let getConfig = (param) => {
  let query = getQueryParam(param)
  if (blitz.position) {
    return blitz.position[param] || query;
  }
  return query;
}

document.addEventListener('paste', function(e) {
  var text = (e.originalEvent || e).clipboardData.getData('text/plain')
  console.log('pasted: ' + text)
})


class Instructions extends Backbone.View {

  get el() {
    return ".instructions"
  }

  initialize() {
    this.showInstructions()
    this.listenForEvents()
  }

  get initialFen() {
    let fen = getConfig("fen") || START_FEN
    console.log(`initial fen is: ${fen}`)
    return fen.length === 4 ? `${fen} 0 1` : fen
  }

  get toMove() {
    return this.initialFen.indexOf("w") > 0 ? "White" : "Black"
  }

  get goal() {
    return getConfig("goal")
  }

  get instructions() {
    if (this.goal === "win") {
      return this.toMove + " to play and win"
    } else if (this.goal === "draw") {
      return this.toMove + " to play and draw"
    }
    return this.toMove + " to move"
  }

  showInstructions() {
    this.$el.text(this.instructions)
    setTimeout(() => this.$el.removeClass("invisible"), 700)
  }

  gameOverMan(result) {
    let text
    if (this.goal === "win") {
      if ((this.toMove === "White" && result === "1-0") ||
          (this.toMove === "Black" && result === "0-1")) {
        text = "You win"
      } else {
        text = "You failed :("
      }
    } else if (this.goal === "draw" && result === "1/2-1/2") {
      text = "Success!"
    } else {
      text = "Game over"
    }
    this.$el.text(text)
    this.$el.removeClass("invisible")
  }

  listenForEvents() {
    this.listenTo(d, "position:reset", () => {
      this.showInstructions()
    })
    this.listenTo(d, "game:over", (result) => {
      this.gameOverMan(result)
    })
    this.listenTo(d, "move:try", () => {
      this.$el.addClass("invisible")
    })
  }
}


class Actions extends Backbone.View {

  get el() {
    return ".actions"
  }

  get events() {
    return {
      "click .restart" : "_resetPosition"
    }
  }

  _resetPosition() {
    d.trigger("position:reset")
  }
}


export default class PositionTrainer extends Backbone.View {

  initialize() {
    this.depth = getConfig("depth") || SEARCH_DEPTH
    this.engine = new StockfishEngine({ multipv: 1 })
    this.setDebugHelpers()
    this.listenForEvents()
    d.trigger("fen:set", this.initialFen)
    if (this.computerColor === "w") {
      d.trigger("board:flip")
    }
    new Instructions()
    new Actions()
  }

  get initialFen() {
    let fen = getConfig("fen") || START_FEN
    return fen.length === 4 ? `${fen} - -` : fen
  }

  get computerColor() {
    return this.initialFen.indexOf("w") > 0 ? "b" : "w"
  }

  setDebugHelpers() {
    window.analyzeFen = (fen, depth) => {
      this.engine.analyze(fen, { depth: depth })
    }
  }

  isComputersTurn(fen) {
    return fen.indexOf(` ${this.computerColor} `) > 0
  }

  listenForEvents() {
    this.listenTo(d, "position:reset", () => {
      d.trigger("fen:set", this.initialFen)
    })

    this.listenTo(d, "fen:set", (fen) => {
      this.currentFen = fen
      this.engine.analyze(fen, { depth: this.depth })
      this.notifyIfGameOver(fen)
    })

    this.listenTo(d, "move:try", (move) => {
      d.trigger("move:make", move)
      d.trigger("move:highlight", move)
    })

    this.listenTo(d, "analysis:done", (data) => {
      if (data.fen != this.currentFen) {
        return
      }
      console.dir(data)
      if (this.isComputersTurn(data.fen)) {
        d.trigger("move:try", uciToMove(data.eval.best))
      }
    })
  }

  notifyIfGameOver(fen) {
    let c = new Chess
    c.load(fen)
    if (!c.game_over()) {
      return
    }
    let result
    if (c.in_draw()) {
      result = "1/2-1/2"
    } else if (c.turn() === "b") {
      result = "1-0"
    } else {
      result = "0-1"
    }
    setTimeout(() => { d.trigger("game:over", result) }, 500)
  }
}
