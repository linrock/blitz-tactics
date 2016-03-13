{

  class Notifier extends Backbone.Model {

    initialize() {
      this.listenToEvents()
    }

    listenToEvents() {
      this.listenTo(d, "puzzles:lap", () => {
        console.log("TODO notify server of attempt")
      })
      this.listenTo(d, "puzzle_sets:next", () => {
        console.log("TODO notify server of success")
      })
    }

  }


  Models.Notifier = Notifier

}
