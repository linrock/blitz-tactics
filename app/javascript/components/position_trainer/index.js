import $ from 'jquery'
import Backbone from 'backbone'
import Chess from 'chess.js'

import StockfishEngine from '../../workers/stockfish_engine'
import InteractiveBoard from '../../views/interactive_board'
import Instructions from './views/instructions'
import Actions from './views/actions'
import { uciToMove, getConfig } from '../../utils'
import d from '../../dispatcher'

const SEARCH_DEPTH = 15
const START_FEN = "rnbqkbnr/pppppppp/8/8/8/8/PPPPPPPP/RNBQKBNR w KQkq - 0 1"


export default class PositionTrainer extends Backbone.View {

  initialize() {
    new InteractiveBoard
    this.depth = getConfig("depth") || SEARCH_DEPTH
    this.engine = new StockfishEngine({ multipv: 1 })
    this.setDebugHelpers()
    this.listenForEvents()
    d.trigger("fen:set", this.initialFen)
    if (this.computerColor === "w") {
      d.trigger("board:flip")
    }
    new Instructions({ fen: this.initialFen })
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

    this.listenTo(d, "fen:set", fen => {
      this.currentFen = fen
      this.engine.analyze(fen, { depth: this.depth })
      this.notifyIfGameOver(fen)
    })

    this.listenTo(d, "move:try", move => d.trigger("move:make", move))

    this.listenTo(d, "analysis:done", data => {
      if (data.fen !== this.currentFen) {
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
    setTimeout(() => d.trigger("game:over", result), 500)
  }
}
