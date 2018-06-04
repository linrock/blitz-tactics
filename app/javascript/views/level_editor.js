import $ from 'jquery'
import _ from 'underscore'
import Backbone from 'backbone'
import Mousetrap from 'mousetrap'

require('jquery-ui')
require('jquery-ui/ui/widgets/sortable')

export default class LevelEditor extends Backbone.View {

  get el() {
    return ".level-editor"
  }

  get events() {
    return {
      "click .board"               : "_toggleSelection",
      "submit .update-level-name"  : "_updateLevelName",
      "submit .add-level"          : "_addLevel"
    }
  }

  initialize() {
    if (!this.$el) {
      return
    }
    this.$addLevelInput = this.$(".add-level-id")
    this.$levelNameInput = this.$(".update-level-name input")
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
      success: html => {
        console.log('updated board ids order')
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

  _updateLevelName(e) {
    $.ajax({
      url: `/${this.$el.data("slug")}`,
      method: "PUT",
      data: {
        name: this.$levelNameInput.val()
      },
      success: () => {
        console.log("name updated");
      }
    });
  }

  _addLevel(e) {
    let newId = this.$addLevelInput.val()
    this.addBoardId(newId)
    this.$addLevelInput.val('').blur()
  }

}
