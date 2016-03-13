{

  class Notifier extends Backbone.Model {

    initialize() {
      this.listenToEvents()
    }

    listenToEvents() {
      this.listenTo(d, "puzzles:lap", this.roundComplete)
      this.listenTo(d, "level:complete", this.levelComplete)
    }

    roundComplete(levelId, payload) {
      console.log("TODO notify server of attempt")
      $.post(`/api/levels/${blitz.levelId}/attempt`)
    }

    levelComplete(levelId) {
      $.post(`/api/levels/${levelId}/complete`, (data) => {
        d.trigger("level:unlocked", data.next.href)
      })
    }

  }


  Models.Notifier = Notifier

}
