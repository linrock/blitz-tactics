import Backbone from 'backbone'

// Level name, next level, etc.
//
export default class LevelIndicator extends Backbone.View {

  get el() {
    return ".under-board"
  }

  initialize() {
    this.$levelName = this.$(".level-name")
    this.$nextStage = this.$(".next-stage")
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenTo(d, "puzzles:start", () => {
      this.$levelName.addClass("faded")
    })
    this.listenTo(d, "level:unlocked", () => {
      this.$nextStage.removeClass("invisible")
      this.$levelName.addClass("invisible")
    })
  }

}
