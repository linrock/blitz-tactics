{

  const comboSizeForNextLevel = 100

  // Indicates # of successful moves in a row
  //
  class ComboCounter extends Backbone.View {

    get el() {
      return ".combo-counter"
    }

    initialize() {
      this.$counter = this.$(".counter")
      this.pzCounter = 0    // Number of puzzles in a row
      this.counter = 0      // Number of moves in a row
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "move:success", () => {
        this.counter += 1
        this.$el.removeClass("invisible")
        if (this.counter > 70) {
          this.$counter.addClass("on-fire")
        } else if (this.counter > 50) {
          this.$counter.addClass("large")
        } else {
          this.$counter.removeClass("on-fire large")
        }
        this.setCounter(this.counter)
      })
      this.listenTo(d, "puzzles:next", () => {
        this.pzCounter += 1
        if (this.nextStageUnlocked()) {
          d.trigger("level:complete")
        }
      })
      this.listenTo(d, "move:fail", () => {
        this.droppedCombo()
      })
      this.listenTo(d, "move:too_slow", () => {
        this.droppedCombo()
      })
    }

    setCounter(counter) {
      this.$counter.text(counter).addClass("emphasis")
      setTimeout(() => { this.$counter.removeClass("emphasis") }, 25)
    }

    checkProgress() {
      let progress = ~~( 100 * this.counter / comboSizeForNextLevel )
      if (progress > 100) {
        progress = 100
      }
      d.trigger("progress:update", progress)
      console.log(progress)
      return progress
    }

    droppedCombo() {
      this.counter = 0
      this.pzCounter = 0
      this.$el.addClass("invisible")
      this.$counter.removeClass("large")
      d.trigger("progress:update", 0)
    }

    nextStageUnlocked() {
      return this.checkProgress() == 100
    }

  }


  Views.ComboCounter = ComboCounter

}
