{

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
      })
    }

    listenToEvents() {
      this.listenTo(d, "puzzles:next", () => {
        this.current = {
          puzzle: this.puzzles[this.i],
          i: 0
        }
        console.log(this.current.puzzle.moves)
        d.trigger("puzzle:loaded", this.current)
        d.trigger("fen:set", this.current.puzzle.fen)
        this.i = (this.i + 1) % this.puzzles.length
      })

      this.listenTo(d, "move:try", (move) => {
        if (this.format == "v1") {
          this.handleV1(move)
        } else {
          this.handleV0(move)
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

  }


  Views.Puzzles = Puzzles

}
