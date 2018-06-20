import _ from 'underscore'
import Backbone from 'backbone'

import { uciToMove, moveToUci, shuffle } from '../../utils'
import d from '../../dispatcher'
import api from '../../api'

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
    this.shuffle = options.shuffle || true
    this.loopPuzzles = options.loopPuzzles || true
    this.fetchPuzzles(options.source)
    this.listenToEvents()
  }

  getPuzzleSource() {
    return window.location.pathname + ".json"
  }

  fetchPuzzles(source) {
    api.get(source || this.getPuzzleSource())
      .then(response => response.data)
      .then(data => {
        this.puzzles = data.puzzles
        d.trigger("puzzles:fetched", this.puzzles)
        d.trigger("config:init", data)
      })
  }

  listenToEvents() {
    this.listenTo(d, "source:changed", path => this.fetchPuzzles(path))
    this.listenTo(d, "puzzles:fetched", () => this.firstPuzzle())
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

  firstPuzzle() {
    this.i = 0
    this.loadPuzzleAtIndex(this.i)
  }

  nextPuzzle() {
    this.i++
    if (this.i + 1 === this.puzzles.length) {
      if (this.shuffle) {
        this.shufflePuzzles()
      }
      if (this.loopPuzzles) {
        this.i = 0
        d.trigger("puzzles:lap")
      } else {
        console.log("oh shit there's no more left")
        d.trigger("puzzles:complete")
      }
    }
    this.loadPuzzleAtIndex(this.i)
  }

  loadPuzzleAtIndex(i) {
    const puzzle = this.puzzles[i]
    this.current = { puzzle }
    d.trigger("puzzle:loaded", this.current)
    this.current.state = _.clone(puzzle.lines)
    d.trigger("fen:set", puzzle.fen)
    setTimeout(() => {
      const move = uciToMove(puzzle.initialMove)
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
      d.trigger("puzzle:solved", this.current.puzzle)
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
      d.trigger("puzzle:solved", this.current.puzzle)
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
