{

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


  class Puzzles extends Backbone.Model {

    initialize() {
      this.i = 0
      this.current = {}
      this.started = false
      this.fetchPuzzles()
      this.listenToEvents()
    }

    getPuzzleSource() {
      if (window.location.pathname.startsWith("/level-")) {
        return window.location.pathname + ".json"
      } else {
        return `/puzzles${window.location.search}`
      }
    }

    fetchPuzzles() {
      $.getJSON(this.getPuzzleSource(), (data) => {
        this.format = data.format
        this.puzzles = data.puzzles
        d.trigger("puzzles:fetched")
      })
    }

    listenToEvents() {
      this.listenTo(d, "puzzles:fetched", _.bind(this.nextPuzzle, this))
      this.listenTo(d, "puzzles:next", _.bind(this.nextPuzzle, this))
      this.listenTo(d, "move:try", _.bind(this.tryMove, this))
    }

    nextPuzzle() {
      this.current = {
        format: this.format,
        puzzle: this.puzzles[this.i],
        i: 0
      }
      d.trigger("puzzle:loaded", this.current)
      if (this.i + 1 === this.puzzles.length) {
        d.trigger("puzzles:lap")
      }
      this.i = (this.i + 1) % this.puzzles.length

      if (this.format == "v0" || this.format == "v1") {
        console.dir(this.current.puzzle)
        console.log(this.current.puzzle.moves)
        d.trigger("fen:set", this.current.puzzle.fen)
      } else if (this.format == "lichess") {
        let puzzle = this.current.puzzle.puzzle
        console.dir(puzzle)
        this.current.state = _.clone(puzzle.lines)
        d.trigger("fen:set", puzzle.fen)
        setTimeout(() => {
          d.trigger("move:make", uciToMove(puzzle.initialMove))
        }, 500)
      }
    }

    tryMove(move) {
      if (!this.started) {
        this.started = true
        d.trigger("puzzles:start")
      }
      if (this.format == "v1") {
        this.handleV1Move(move)
      } else if (this.format == "v0") {
        this.handleV0Move(move)
      } else if (this.format == "lichess") {
        this.handleLichessMove(move)
      }
    }

    handleV0Move(move) {
      let solution = this.current.puzzle.solution
      if (move.from == solution[0][0] && move.to == solution[0][1]) {
        solution.shift()
        d.trigger("move:make", move)
        if (solution.length == 0) {
          d.trigger("puzzles:next")
          return
        }
        let response = solution.shift()
        d.trigger("move:make", {
          from: response[0],
          to: response[1]
        })
      }
      if (solution.length == 0) {
        d.trigger("puzzles:next")
      }
    }

    handleV1Move(move) {
      let moves = this.current.puzzle.moves
      let nextMove = moves[this.current.i]
      if (move.san == nextMove) {
        d.trigger("move:make", move)
        this.current.i += 1
        if (this.current.i == moves.length) {
          d.trigger("puzzles:next")
          return
        }
        d.trigger("move:make", moves[this.current.i])
        this.current.i += 1
      }
      if (this.current.i == moves.length) {
        d.trigger("puzzles:next")
      }
    }

    handleLichessMove(move) {
      let attempt = this.current.state[moveToUci(move)]
      if (attempt == "win") {
        d.trigger("move:success")
        d.trigger("puzzles:next")
        return
      } else {
        let response = _.keys(attempt)[0]
        if (!response) {
          d.trigger("move:fail")
          return
        }
        d.trigger("move:make", move)
        d.trigger("move:success")
        d.trigger("move:make", uciToMove(response))
        if (attempt[response] == "win") {
          d.trigger("puzzles:next")
        } else {
          this.current.state = attempt[response]
        }
      }
    }

  }


  // TODO not a view
  Models.Puzzles = Puzzles

}
