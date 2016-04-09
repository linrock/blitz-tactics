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
        this.setCounter(this.counter)
      })
      this.listenTo(d, "move:fail", _.bind(this.droppedCombo, this))
      this.listenTo(d, "move:too_slow", _.bind(this.droppedCombo, this))
    }

    setCounter(counter) {
      this.$counter.text(counter).addClass("emphasis")
      setTimeout(() => { this.$counter.removeClass("emphasis") }, 25)
    }

    droppedCombo() {
      this.counter = 0
      this.$el.addClass("invisible")
      this.$counter.removeClass("large")
    }

  }


  Views.ComboCounter = ComboCounter

}
