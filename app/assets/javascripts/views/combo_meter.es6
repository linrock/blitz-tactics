{

  // Indicates # of successful moves in a row
  //
  class ComboMeter extends Backbone.View {

    get el() {
      return $(".combo-meter")
    }

    initialize() {
      this.counter = 0
      this.$counter = this.$(".counter")
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "move:success", () => {
        this.counter += 1
        this.$el.fadeIn(75)
        this.$counter.text(this.counter)
      })
      this.listenTo(d, "move:fail", () => {
        this.counter = 0
        this.$el.fadeOut(75)
      })
      this.listenTo(d, "move:too_slow", () => {
        this.counter = 0
        this.$el.fadeOut(75)
      })
    }

  }


  Views.ComboMeter = ComboMeter

}
