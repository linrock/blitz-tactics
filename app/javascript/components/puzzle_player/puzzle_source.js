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
    this.puzzles = []
    this.started = false
    this.shuffle = options.shuffle
    this.loopPuzzles = options.loopPuzzles
    this.fetchPuzzles(options.source)
    this.listenToEvents()
  }

  fetchPuzzles(source) {
    fetchPuzzles(source).then(data => {
      d.trigger("puzzles:fetched", data.puzzles)
      d.trigger("config:init", data)
    })
  }

  fetchAndAddPuzzles(source) {
    fetchPuzzles(source).then(data => d.trigger("puzzles:added", data.puzzles))
  }

  listenToEvents() {
    this.listenTo(d, "source:changed", path => this.fetchPuzzles(path))
    this.listenTo(d, "source:changed:add", path => this.fetchAndAddPuzzles(path))
    this.listenTo(d, "puzzles:fetched", puzzles => {
      this.puzzles = []
      this.addPuzzles(puzzles)
      this.firstPuzzle()
    })
    this.listenTo(d, "puzzles:added", puzzles => this.addPuzzles(puzzles))
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

  addPuzzles(puzzles) {
    this.puzzles = this.puzzles.concat(puzzles)
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
    if (i === 0 && !puzzle) {
      d.trigger("puzzles:complete")
      return
    }
    this.current = {
      boardState: _.clone(puzzle.lines),
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
    const attempt = this.current.boardState[moveToUci(move)]
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
        this.current.boardState = attempt[response]
      }, responseDelay)
    }
  }

  puzzleSolved() {
    const n = this.puzzles.length
    d.trigger("puzzle:solved", this.current.puzzle)
    d.trigger("puzzles:status", {
      i: this.i,
      lastPuzzleId: this.puzzles[n - 1].id,
      n,
    })
    d.trigger("puzzles:next")
  }
}
