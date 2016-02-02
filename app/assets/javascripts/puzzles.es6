{

  class Puzzles extends Backbone.Model {

    initialize() {
      this.i = 0
      this.currentPuzzle = false
      $.getJSON("/puzzles", (data) => {
        this.puzzles = data
      })
      this.listenToEvents()
    }

    listenToEvents() {
      this.listenTo(d, "puzzles:next", () => {
        this.currentPuzzle = this.puzzles[this.i]
        d.trigger("fen:set", this.currentPuzzle.fen)
        this.i = (this.i + 1) % this.puzzles.length
      })

      this.listenTo(d, "move:try", (move) => {
        let solution = this.currentPuzzle.solution
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
      })
    }

  }


  Views.Puzzles = Puzzles

}
