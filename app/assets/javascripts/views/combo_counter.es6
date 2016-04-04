{

  // Indicates # of successful moves in a row
  //
  class ComboCounter extends Backbone.View {

    get el() {
      return ".combo-counter"
    }

    initialize() {
      this.counter = 0
      this.$counter = this.$(".counter")
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

    droppedCombo() {
      this.counter = 0
      this.$el.addClass("invisible")
      this.$counter.removeClass("large")
      d.trigger("progress:update", 0)
    }

  }


  Views.ComboCounter = ComboCounter

}
