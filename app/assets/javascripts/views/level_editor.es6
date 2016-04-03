{

  class LevelEditor extends Backbone.View {

    get el() {
      return ".level-editor"
    }

    initialize() {
      if (!this.$el) {
        return
      }
      this.$(".boards").sortable({
        update: (event, ui) => {
          console.log(this.sortedBoardIds())
        }
      })
    }

    sortedBoardIds() {
      return _.map(this.$(".mini-chessboard"), (board) => {
        return $(board).data("id")
      }))
    }

  }


  Views.LevelEditor = LevelEditor

}
