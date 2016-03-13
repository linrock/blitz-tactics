{

  class Notifier extends Backbone.Model {

    initialize() {
      this.listenToEvents()
    }

    listenToEvents() {
      this.listenTo(d, "round:complete", this.roundComplete)
      this.listenTo(d, "level:complete", this.levelComplete)
    }

    roundComplete(levelId, payload) {
      $.post(`/api/levels/${levelId}/attempt`, { round: payload })
    }

    levelComplete(levelId) {
      $.post(`/api/levels/${levelId}/complete`, (data) => {
        d.trigger("level:unlocked", data.next.href)
      })
    }

  }


  Models.Notifier = Notifier

}
