import Backbone from 'backbone'

import d from '../dispatcher'

// Main header hides for logged-in users, and fades for logged out
//
export default class MainHeader extends Backbone.View {

  get el() {
    return ".main-header"
  }

  initialize() {
    // TODO disable this for now
    // this.listenToEvents()
  }

  listenToEvents() {
    this.listenTo(d, "puzzles:start", () => {
      if (blitz.loggedIn) {
        this.$el.addClass("hidden");
      } else {
        this.$el.addClass("faded");
      }
    })
  }
}
