{

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
      
    }

    _startPuzzles() {
      d.trigger("puzzles:next")
    }

  }


  Views.StartButton = StartButton

}
