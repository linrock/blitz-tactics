{

  const comboDroppedIn = 7000
  const hintDelay = 750

  // Solution/hint that shows up after some time
  //
  class PuzzleHint extends Backbone.View {

    get el() {
      return ".puzzle-hint"
    }

    initialize() {
      this.timeout = false
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "puzzle:loaded", (current) => {
        this.current = current
        this.delayedShowHint()
      })
      this.listenTo(d, "move:make", () => {
        this.delayedShowHint()
      })
    }

    delayedShowHint() {
      if (this.timeout) {
        clearTimeout(this.timeout)
      }
      this.$el.addClass("invisible").text("")
      this.timeout = setTimeout(() => {
        d.trigger("move:too_slow")
        setTimeout(() => {
          this.showHint()
        }, hintDelay)
      }, comboDroppedIn)
    }

    showHint() {
      let hints = []
      _.each(_.keys(this.current.state), (move) => {
        if (this.current.state[move] !== "retry") {
          hints.push(move)
        }
      })
      this.$el.removeClass("invisible").text(`Hint - ${_.sample(hints)}`)
    }

  }


  Views.PuzzleHint = PuzzleHint;

}
