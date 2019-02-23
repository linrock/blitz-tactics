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

  initialize() {
    this.instructionsEl = this.el.querySelector(`.instructions`)
    this.playerRatingEl = this.el.querySelector(`.player-rating`)
    this.nPuzzlesEl = this.el.querySelector(`.n-puzzles`)
    this.movesAttemptedEl = this.el.querySelector(`.moves-attempted`)
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
    const el = this.moveAttemptEl(moveSan, className)
    this.movesAttemptedEl.prepend(el)
    setTimeout(() => el.classList.remove(`invisible`), 0)
  }

  moveAttemptEl(moveSan, className) {
    const moveEl = document.createElement(`div`)
    moveEl.classList.add(`move-attempt`)
    moveEl.classList.add(`invisible`)
    moveEl.classList.add(className)
    const svgId = className === `fail` ? `#x-mark` : `#check-mark`
    moveEl.innerHTML = `
      <svg viewBox="0 0 45 45">
        <use xlink:href="${svgId}" width="100%" height="100%"></use>
      </svg>
      <div class="move-san">${moveSan}</div>
    `
    return moveEl
  }
}
