import $ from 'jquery'
import _ from 'underscore'
import Backbone from 'backbone'

const responseDelay = 0


let uciToMove = (uci) => {
  let m = {
    from: uci.slice(0,2),
    to: uci.slice(2,4)
  }
  if (uci.length === 5) {
    m.promotion = uci[4]
  }
  return m
}

let moveToUci = (move) => {
  if (move.promotion) {
    return `${move.from}${move.to}${move.promotion}`
  } else {
    return `${move.from}${move.to}`
  }
}

function shuffle(original) {
  let array = original.slice(0)
  let counter = array.length
  while (counter > 0) {
    let index = Math.floor(Math.random() * counter)
    counter--
    let temp = array[counter]
    array[counter] = array[index]
    array[index] = temp
  }
  return array
}

export default class Puzzles extends Backbone.Model {

  initialize(options = {}) {
    this.i = 0
    this.current = {}
    this.started = false
    this.fetchPuzzles(options.source)
    this.listenToEvents()
  }

  getPuzzleSource() {
    return window.location.pathname + ".json"
  }

  fetchPuzzles(source) {
    if (!source) {
      source = this.getPuzzleSource()
    }
    $.getJSON(source, (data) => {
      this.puzzles = data.puzzles
      d.trigger("puzzles:fetched", this.puzzles)
    })
  }

  listenToEvents() {
    this.listenTo(d, "puzzles:fetched", _.bind(this.nextPuzzle, this))
    this.listenTo(d, "puzzles:next", _.bind(this.nextPuzzle, this))
    this.listenTo(d, "move:try", _.bind(this.tryUserMove, this))
  }

  shufflePuzzles() {
    let shuffled = shuffle(this.puzzles)
    while (shuffled[0].fen === this.puzzles[this.puzzles.length-1].fen) {
      shuffled = shuffle(this.puzzles)
    }
    this.puzzles = shuffled
  }

  nextPuzzle() {
    this.current = {
      puzzle: this.puzzles[this.i],
      i: 0
    }
    d.trigger("puzzle:loaded", this.current)
    if (this.i + 1 === this.puzzles.length) {
      this.shufflePuzzles()
      d.trigger("puzzles:lap")
    }
    this.i = (this.i + 1) % this.puzzles.length
    let puzzle = this.current.puzzle
    console.dir(puzzle)
    this.current.state = _.clone(puzzle.lines)
    d.trigger("fen:set", puzzle.fen)
    setTimeout(() => {
      let move = uciToMove(puzzle.initialMove)
      d.trigger("move:make", move)
      d.trigger("move:highlight", move)
    }, 500)
  }

  tryUserMove(move) {
    if (!this.started) {
      this.started = true
      d.trigger("puzzles:start")
    }
    this.handleUserMove(move)
  }

  handleUserMove(move) {
    let attempt = this.current.state[moveToUci(move)]
    if (attempt === "win") {
      d.trigger("move:success")
      d.trigger("puzzles:next")
      return
    } else if (attempt === "retry") {
      d.trigger("move:almost")
      return
    }
    let response = _.keys(attempt)[0]
    if (!response) {
      d.trigger("move:fail")
      return
    }
    d.trigger("move:make", move)
    d.trigger("move:success")
    if (attempt[response] === "win") {
      d.trigger("puzzles:next")
    } else {
      let responseMove = uciToMove(response)
      if (responseDelay > 0) {
        setTimeout(() => {
          d.trigger("move:make", responseMove)
          d.trigger("move:highlight", responseMove)
          this.current.state = attempt[response]
        }, responseDelay)
      } else {
        d.trigger("move:make", responseMove)
        d.trigger("move:highlight", responseMove)
        this.current.state = attempt[response]
      }
    }
  }
}
