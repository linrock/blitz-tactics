{

  // Click this to start the puzzles
  //
  class StartButton extends Backbone.View {

    get el() {
      return $(".start")
    }

    get events() {
      return {
        "click" : "_startPuzzles"
      }
    }

    initialize() {
      this.listenTo(d, "puzzles:fetched", () => {
        this.$el.removeClass("disabled")
      })
    }

    _startPuzzles() {
      $(".overlay").hide()
      d.trigger("puzzles:next")
    }

  }


  Views.StartButton = StartButton

}
