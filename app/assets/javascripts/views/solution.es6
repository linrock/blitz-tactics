{

  const hintDelay = 7000

  // Solution/hint that shows up after some time
  //
  class Solution extends Backbone.View {

    get el() {
      return ".solution"
    }

    initialize() {
      this.timeout = false
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "puzzle:loaded", (current) => {
        this.current = current
        this.delayedShowSolution()
      })
      this.listenTo(d, "move:make", () => {
        this.delayedShowSolution()
      })
    }

    delayedShowSolution() {
      if (this.timeout) {
        clearTimeout(this.timeout)
      }
      this.$el.addClass("invisible").text("")
      this.timeout = setTimeout(() => {
        this.showSolution()
      }, hintDelay)
    }

    showSolution() {
      d.trigger("move:too_slow")
      this.$el.removeClass("invisible")
      if (this.current.format === "lichess") {
        let hints = []
        _.each(_.keys(this.current.state), (move) => {
          if (this.current.state[move] !== "retry") {
            hints.push(move)
          }
        })
        this.$el.text(`Hint: ${_.sample(hints)}`)
      } else {
        this.$el.text(this.current.puzzle.moves)
      }
    }

  }


  Views.Solution = Solution

}
