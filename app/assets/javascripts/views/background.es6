{

  class Background extends Backbone.View {

    get el() {
      return "body"
    }

    initialize() {
      this.listenForEvents()
    }

    listenForEvents() {
      this.listenTo(d, "level:unlocked", () => {
        this.$el.css("background", "#373737")
      })
    }

  }


  Views.Background = Background

}
