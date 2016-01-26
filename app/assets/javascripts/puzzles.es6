{

  class Puzzles extends Backbone.Model {

    initialize() {
      this.i = 0
      $.getJSON("/puzzles", (data) => {
        this.puzzles = data
      })
      this.listenToEvents()
    }

    listenToEvents() {
      this.listenTo(d, "puzzles:next", () => {
        d.trigger("fen:set", this.puzzles[this.i].fen)
        this.i = (this.i + 1) % this.puzzles.length
      })
    }

  }


  Views.Puzzles = Puzzles

}
