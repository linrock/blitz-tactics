{

  class LevelEditor extends Backbone.View {

    get el() {
      return ".level-editor"
    }

    get events() {
      return {
        "click .board"       : "_toggleSelection",
        "submit .add-level"  : "_addLevel"
      }
    }

    initialize() {
      if (!this.$el) {
        return
      }
      this.$addLevelInput = this.$(".add-level-id")
      this.makeBoardsSortable()
      this.bindKeyboardEvents()
    }

    makeBoardsSortable() {
      this.$(".boards").sortable({
        distance: 15,
        update: (event, ui) => {
          this.updateBoardIds(this.sortedBoardIds())
        }
      })
    }

    bindKeyboardEvents() {
      Mousetrap.bind('backspace', _.bind(this.deleteSelectedBoardIds, this))
    }

    getBoardIds($boards) {
      return _.map($boards, (board) => {
        return $(board).data("id")
      })
    }

    sortedBoardIds() {
      return this.getBoardIds(this.$(".mini-chessboard"))
    }

    deleteSelectedBoardIds() {
      let selectedIds = this.getBoardIds(this.$(".board.selected .mini-chessboard"))
      let newIds = _.difference(this.sortedBoardIds(), selectedIds)
      this.updateBoardIds(newIds)
      this.$(".board.selected").remove()
    }

    updateBoardIds(ids) {
      $.ajax({
        url: `/${this.$el.data("slug")}`,
        method: "PUT",
        data: {
          puzzle_ids: ids
        },
        success: (html) => {
          this.$(".boards").html(html)
        }
      })
    }

    addBoardId(id) {
      this.updateBoardIds([id].concat(this.sortedBoardIds()))
    }

    _toggleSelection(e) {
      let $board = $(e.currentTarget)
      $board.toggleClass("selected")
    }

    _addLevel(e) {
      let newId = this.$addLevelInput.val()
      this.addBoardId(newId)
      this.$addLevelInput.val('').blur()
    }

  }


  Views.LevelEditor = LevelEditor

}
