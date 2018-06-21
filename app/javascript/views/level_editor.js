import $ from 'jquery'
import _ from 'underscore'
import Backbone from 'backbone'
import Mousetrap from 'mousetrap'
require('jquery-ui')
require('jquery-ui/ui/widgets/sortable')

import api from '../api'

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
      update: (event, ui) => this.updateBoardIds(this.sortedBoardIds())
    })
  }

  bindKeyboardEvents() {
    Mousetrap.bind('backspace', () => this.deleteSelectedBoardIds())
  }

  getBoardIds($boards) {
    return $boards.toArray().map(board => board.dataset.id)
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
    const data = {
      puzzle_ids: ids
    }
    api.put(`/${this.$el.data("slug")}`, data)
      .then(response => response.data)
      .then(html => {
        console.log('updated board ids order')
      })
  }

  addBoardId(id) {
    this.updateBoardIds([id].concat(this.sortedBoardIds()))
  }

  _toggleSelection(e) {
    const $board = $(e.currentTarget)
    $board.toggleClass("selected")
  }

  _updateLevelName(e) {
    const data = {
      name: this.$levelNameInput.val()
    }
    api.put(`/${this.$el.data("slug")}`, data)
      .then(response => response.data)
      .then(() => {
        console.log("name updated")
      })
  }

  _addLevel(e) {
    let newId = this.$addLevelInput.val()
    this.addBoardId(newId)
    this.$addLevelInput.val('').blur()
  }
}
