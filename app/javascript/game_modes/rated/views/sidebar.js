// instructions fade out after you start
// updates player rating as it changes
// shows a list of the moves you attempted

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Sidebar extends Backbone.View {

  get el() {
    return document.querySelector(`.rated-sidebar`)
  }

  get events() {
    return {
      'click .start-button': () => d.trigger(`puzzles:next`)
    }
  }

  get instructionsEl() {
    return this.el.querySelector(`.instructions`)
  }

  get playerRatingEl() {
    return this.el.querySelector(`.player-rating`)
  }

  get nPuzzlesEl() {
    return this.el.querySelector(`.n-puzzles`)
  }

  get movesAttemptedEl() {
    return this.el.querySelector(`.moves-attempted`)
  }

  initialize() {
    this.listenToOnce(d, `puzzles:next`, () => {
      this.instructionsEl.remove()
      this.movesAttemptedEl.style = ``
    })
    this.listenTo(d, `rated_puzzle:attempted`, data => {
      this.playerRatingEl.textContent =
        Math.round(data.rated_puzzle_attempt.post_user_rating)
      this.nPuzzlesEl.textContent =
        data.user_rating.rated_puzzle_attempts_count
    })
    this.listenTo(d, `move:make`, (move, options = {}) => {
      if (!options.opponent) {
        console.log(JSON.stringify(move))
        this.addMoveAttempt(move.san, `success`)
      }
    })
    this.listenTo(d, `move:fail`, move => {
      this.addMoveAttempt(move.san, `fail`)
    })
    this.listenTo(d, `move:almost`, move => {
      this.addMoveAttempt(move.san, `almost`)
    })
  }

  addMoveAttempt(moveSan, className) {
    this.movesAttemptedEl.prepend(this.moveAttemptEl(moveSan, className))
  }

  moveAttemptEl(moveSan, className) {
    const moveEl = document.createElement(`div`)
    moveEl.classList.add(`move-attempt`)
    moveEl.classList.add(className)
    moveEl.textContent = moveSan
    return moveEl
  }
}
