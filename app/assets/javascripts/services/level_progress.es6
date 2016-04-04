{

  // Tracks progress within the level and whether the next level is unlocked
  //
  class LevelProgress extends Backbone.Model {

    initialize() {
      this.pzCounter = 0
      this.n = 0
      this.unlocked = false
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "puzzles:fetched", (puzzles) => {
        this.n = puzzles.length
      })
      this.listenTo(d, "puzzles:next", () => {
        this.pzCounter += 1
        if (!this.unlocked && this.nextStageUnlocked()) {
          this.unlocked = true
          d.trigger("level:complete", blitz.levelId)
        }
      })
    }

    nextStageUnlocked() {
      return this.checkProgress() == 100
    }

    checkProgress() {
      let progress = ~~( 100 * this.pzCounter / this.n )
      if (progress > 100) {
        progress = 100
      }
      d.trigger("progress:update", progress)
      return progress
    }

  }


  Services.LevelProgress = LevelProgress

}
