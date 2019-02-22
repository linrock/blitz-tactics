// instructions that fade out after you start

import Backbone from 'backbone'

import d from '../../../dispatcher'

export default class Sidebar extends Backbone.View {

  get el() {
    return document.querySelector(`.rated-sidebar`)
  }

  get instructionsEl() {
    return this.el.querySelector(`.instructions`)
  }

  get playerRatingEl() {
    return this.el.querySelector(`.player-rating`)
  }

  initialize() {
    this.listenToOnce(d, `move:try`, () => this.instructionsEl.remove())
    this.listenTo(d, `rated_puzzle:attempted`, data => {
      this.playerRatingEl.textContent = Math.round(data.post_user_rating)
    })
  }
}
