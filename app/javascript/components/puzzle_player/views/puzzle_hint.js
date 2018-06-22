import _ from 'underscore'
import Backbone from 'backbone'

import d from '../../../dispatcher'

const comboDroppedAfter = 7000
const hintDelay = 750

// Solution/hint that shows up after some time
//
export default class PuzzleHint extends Backbone.View {

  get el() {
    return ".puzzle-hint"
  }

  get events() {
    return {
      "mousedown .hint-trigger" : "_showHint",
      "touchstart .hint-trigger" : "_showHint"
    }
  }

  initialize() {
    this.timeout = false
    this.$move = this.$(".move")
    this.$button = this.$(".hint-trigger")
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenTo(d, "puzzle:loaded", current => {
      this.current = current
      this.delayedShowHint()
    })
    this.listenTo(d, "move:make", () => this.delayedShowHint())
  }

  delayedShowHint() {
    if (this.timeout) {
      clearTimeout(this.timeout)
    }
    this.$el.addClass("invisible")
    this.$button.hide()
    this.$move.text("")
    this.timeout = setTimeout(() => {
      d.trigger("move:too_slow")
      setTimeout(() => this.showHint(), hintDelay)
    }, comboDroppedAfter)
  }

  showHint() {
    const hints = []
    _.each(_.keys(this.current.boardState), move => {
      if (this.current.boardState[move] !== "retry") {
        hints.push(move)
      }
    })
    this.$el.removeClass("invisible")
    this.$button.fadeIn(80)
    this.$move.text(_.sample(hints))
  }

  _showHint() {
    this.$button.fadeOut(80)
  }
}
