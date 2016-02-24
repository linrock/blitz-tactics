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
      this.fetchPuzzles()
      this.listenToEvents()
    }

    fetchPuzzles() {
      let url = `/puzzles${window.location.search}`
      $.getJSON(url, (data) => {
        this.format = data.format
        this.puzzles = data.puzzles
        d.trigger("puzzles:fetched")
      })
    }

    listenToEvents() {
      this.listenTo(d, "puzzles:next", () => {
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
      })

      this.listenTo(d, "move:try", (move) => {
        if (this.format == "v1") {
          this.handleV1(move)
        } else if (this.format == "v0") {
          this.handleV0(move)
        } else if (this.format == "lichess") {
          this.handleLichess(move)
        }
      })
    }

    handleV0(move) {
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

    handleV1(move) {
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

    handleLichess(move) {
      let attempt = this.current.state[moveToUci(move)]
      if (attempt == "win") {
        d.trigger("puzzles:next")
        return
      } else {
        let response = _.keys(attempt)[0]
        if (!response) {
          return
        }
        d.trigger("move:make", move)
        d.trigger("move:make", uciToMove(response))
        if (attempt[response] == "win") {
          d.trigger("puzzles:next")
        } else {
          this.current.state = attempt[response]
        }
      }
    }

  }


  Views.Puzzles = Puzzles

}
