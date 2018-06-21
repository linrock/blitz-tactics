import _ from 'underscore'
import Backbone from 'backbone'

import { uciToMove, moveToUci, shuffle } from '../../utils'
import { fetchPuzzles } from '../../api/requests'
import d from '../../dispatcher'

// source:changed
// puzzles:fetched
// puzzles:start
// puzzles:lap
// puzzle:loaded
// fen:set
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
    this.shuffle = options.shuffle
    this.loopPuzzles = options.loopPuzzles
    this.fetchPuzzles(options.source)
    this.listenToEvents()
  }

  fetchPuzzles(source) {
    fetchPuzzles(source).then(data => {
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
    while (shuffled[0].fen === this.puzzles[this.puzzles.length - 1].fen) {
      shuffled = shuffle(this.puzzles)
    }
    this.puzzles = shuffled
  }

  firstPuzzle() {
    this.i = 0
    this.loadPuzzleAtIndex(this.i)
  }

  nextPuzzle() {
    this.i = this.i + 1
    if (this.i === this.puzzles.length) {
      if (this.shuffle) {
        this.shufflePuzzles()
      }
      if (this.loopPuzzles) {
        this.i = 0
        d.trigger("puzzles:lap")
        this.loadPuzzleAtIndex(this.i)
      } else {
        d.trigger("puzzles:complete")
      }
    } else {
      this.loadPuzzleAtIndex(this.i)
    }
  }

  getInitialMoveSan(move) {
    if (move.san) {
      return move.san
    } else {
      return move.uci ? uciToMove(move.uci) : uciToMove(move)
    }
  }

  loadPuzzleAtIndex(i) {
    const puzzle = this.puzzles[i]
    this.current = {
      state: _.clone(puzzle.lines),
      puzzle,
    }
    d.trigger("puzzle:loaded", this.current)
    d.trigger("fen:set", puzzle.fen)
    setTimeout(() => {
      const move = this.getInitialMoveSan(puzzle.initialMove)
      d.trigger("move:make", move)
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
    const attempt = this.current.state[moveToUci(move)]
    if (attempt === "win") {
      d.trigger("move:success")
      this.puzzleSolved()
      return
    } else if (attempt === "retry") {
      d.trigger("move:almost")
      return
    }
    const response = _.keys(attempt)[0]
    if (!response) {
      d.trigger("move:fail")
      return
    }
    d.trigger("move:make", move, false)
    d.trigger("move:success")
    if (attempt[response] === "win") {
      this.puzzleSolved()
    } else {
      const responseMove = uciToMove(response)
      setTimeout(() => {
        d.trigger("move:make", responseMove)
        this.current.state = attempt[response]
      }, responseDelay)
    }
  }

  puzzleSolved() {
    d.trigger("puzzle:solved", this.current.puzzle)
    d.trigger("puzzles:next")
  }
}
