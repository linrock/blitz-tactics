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

    tryMove(move) {
      if (!this.started) {
        this.started = true
        d.trigger("puzzles:start")
      }
      this.handleMove(move)
    }

    handleMove(move) {
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
        if (attempt[response] == "win") {
          d.trigger("puzzles:next")
        } else {
          d.trigger("move:make", uciToMove(response))
          d.trigger("move:highlight", uciToMove(response))
          this.current.state = attempt[response]
        }
      }
    }

  }


  Services.Puzzles = Puzzles

}
