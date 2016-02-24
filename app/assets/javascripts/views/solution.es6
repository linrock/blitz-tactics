{

  class Solution extends Backbone.View {

    get el() {
      return $(".solution")
    }

    initialize() {
      this.interval = false
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
      if (this.interval) {
        clearInterval(this.interval)
      }
      this.$el.text('')
      this.interval = setInterval(() => {
        this.showSolution()
      }, 7000)
    }

    showSolution() {
      if (this.current.format === "lichess") {
        this.$el.text(_.keys(this.current.state))
      } else {
        this.$el.text(this.current.puzzle.moves)
      }
    }

  }


  Views.Solution = Solution

}
