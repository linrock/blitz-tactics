import Backbone from 'backbone'

export default class Background extends Backbone.View {

  get el() {
    return "body"
  }

  initialize() {
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenTo(d, "level:unlocked", () => {
      this.$el.addClass("unlocked")
    })
  }
}
