// fetches puzzles from the server, handles player moves,
// and emits move events (move:success, move:almost, move:fail)

import _ from 'underscore'
import Backbone from 'backbone'

import { uciToMove, moveToUci, shuffle } from '../../utils'
import { fetchPuzzles } from '../../api/requests'
import Listener from '../../listener'
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

// de-duplicates puzzles
class Puzzles {

  constructor(options) {
    this.puzzleList = []
    this.puzzleSet = new Set()
  }

  addPuzzles(puzzles) {
    puzzles.forEach(puzzle => {
      if (!this.puzzleSet.has(puzzle.id)) {
        this.puzzleSet.add(puzzle.id)
        this.puzzleList.push(puzzle)
      }
    })
  }

  shuffle() {
    let shuffled = shuffle(this.puzzleList)
    while (this.lastPuzzle().fen === shuffled[0].fen) {
      shuffled = shuffle(this.puzzleList)
    }
    this.puzzleList = shuffled
  }

  count() {
    return this.puzzleList.length
  }

  puzzleAt(index) {
    return this.puzzleList[index]
  }

  lastPuzzle() {
    return this.puzzleAt(this.count() - 1)
  }
}

export default class PuzzleSource {

  // options - shuffle, loopPuzzles, source
  constructor(options = {}) {
    this.i = 0
    this.current = {}
    this.puzzles = new Puzzles()
    this.started = false
    this.shuffle = options.shuffle
    this.loopPuzzles = options.loopPuzzles
    this.mode = options.mode
    this.fetchPuzzles(options.source)
    this.listenToEvents()
  }

  fetchPuzzles(source) {
    fetchPuzzles(source).then(data => {
      d.trigger(`puzzles:fetched`, data.puzzles)
      d.trigger(`config:init`, data)
    })
  }

  fetchAndAddPuzzles(source) {
    fetchPuzzles(source).then(data => d.trigger(`puzzles:added`, data.puzzles))
  }

  listenToEvents() {
    new Listener({
      'source:changed': path => this.fetchPuzzles(path),
      'source:changed:add': path => this.fetchAndAddPuzzles(path),
      'puzzles:fetched': puzzles => {
        this.puzzles = new Puzzles()
        this.addPuzzles(puzzles)
        this.firstPuzzle()
      },
      'puzzles:added': puzzles => this.addPuzzles(puzzles),
      'puzzles:next': () => {
        const n = this.puzzles.count()
        d.trigger(`puzzles:status`, {
          i: this.i,
          lastPuzzleId: this.puzzles.lastPuzzle().id,
          n,
        })
        this.nextPuzzle()
      },
      'move:try': move => this.tryUserMove(move),
    })
  }

  addPuzzles(puzzles) {
    this.puzzles.addPuzzles(puzzles)
  }

  firstPuzzle() {
    this.i = 0
    this.loadPuzzleAtIndex(this.i)
  }

  nextPuzzle() {
    this.i = this.i + 1
    if (this.i === this.puzzles.count()) {
      if (this.shuffle) {
        this.puzzles.shuffle()
      }
      if (this.loopPuzzles) {
        this.i = 0
        d.trigger(`puzzles:lap`)
        this.loadPuzzleAtIndex(this.i)
      } else {
        d.trigger(`puzzles:complete`)
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
    const puzzle = this.puzzles.puzzleAt(i)
    this.current = {
      boardState: Object.assign({}, puzzle.lines),
      puzzle,
    }
    d.trigger(`puzzle:loaded`, this.current)
    d.trigger(`board:flipped`, !!puzzle.fen.match(/ w /))
    d.trigger(`fen:set`, puzzle.fen)
    setTimeout(() => {
      const move = this.getInitialMoveSan(puzzle.initialMove)
      d.trigger(`move:make`, move, { opponent: true })
      d.trigger(`move:sound`, move)
    }, 500)
  }

  tryUserMove(move) {
    if (!this.started) {
      this.started = true
      d.trigger(`puzzles:start`)
    }
    this.handleUserMove(move)
  }

  handleUserMove(move) {
    const attempt = this.current.boardState[moveToUci(move)]
    if (attempt === `win`) {
      d.trigger(`move:success`)
      if (this.mode === `rated`) {
        d.trigger(`move:make`, move)
      } else if (this.i === this.puzzles.count() - 1) {
        // TODO look into whether this check is needed
        d.trigger(`move:make`, move)
      }
      this.puzzleSolved()
      return
    } else if (attempt === `retry`) {
      d.trigger(`move:almost`, move)
      return
    }
    const response = _.keys(attempt)[0]
    if (!response) {
      d.trigger(`move:fail`, move)
      return
    }
    d.trigger(`move:make`, move)
    d.trigger(`move:success`)
    if (attempt[response] === `win`) {
      this.puzzleSolved()
    } else {
      d.trigger(`move:sound`, move)
      const responseMove = uciToMove(response)
      setTimeout(() => {
        d.trigger(`move:make`, responseMove, { opponent: true })
        this.current.boardState = attempt[response]
      }, responseDelay)
    }
  }

  puzzleSolved() {
    d.trigger(`puzzle:solved`, this.current.puzzle)
    d.trigger(`puzzles:next`)
  }
}
