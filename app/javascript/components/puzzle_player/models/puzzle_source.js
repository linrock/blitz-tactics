import _ from 'underscore'
import Backbone from 'backbone'

import { uciToMove, moveToUci, shuffle } from '../../../utils'
import d from '../../../dispatcher'
import api from '../../../api'

// list of events

// puzzles:fetched
// puzzles:start
// puzzles:lap
// puzzle:loaded
// fen:set
// move:highlight
// move:make
// move:almost
// move:success
// move:fail


const responseDelay = 0

export default class PuzzleSource extends Backbone.Model {

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
    api.get(source)
      .then(response => response.data)
      .then(data => {
        this.puzzles = data.puzzles
        d.trigger("puzzles:fetched", this.puzzles)
      })
  }

  listenToEvents() {
    this.listenTo(d, "source:changed", path => this.fetchPuzzles(path))
    this.listenTo(d, "puzzles:fetched", () => this.nextPuzzle())
    this.listenTo(d, "puzzles:next", () => this.nextPuzzle())
    this.listenTo(d, "move:try", move => this.tryUserMove(move))
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
