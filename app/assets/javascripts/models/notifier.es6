{

  class Notifier extends Backbone.Model {

    initialize() {
      this.listenToEvents()
    }

    listenToEvents() {
      this.listenTo(d, "puzzles:lap", () => {
        console.log("TODO notify server of attempt")
        $.post(`/api/v1/puzzles/${blitz.levelId}/attempt`)
      })
      this.listenTo(d, "level:complete", () => {
        $.post(`/api/v1/puzzles/${blitz.levelId}/attempt`, (data, error) => {
          if (error) {
            console.error(error)
          } else {
            d.trigger("level:unlocked", data.next.href)
          }
        })
      })
    }

  }


  Models.Notifier = Notifier

}
