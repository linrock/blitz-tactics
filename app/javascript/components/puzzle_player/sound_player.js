import Backbone from 'backbone'

import d from '../../dispatcher'

const soundEnabled = false

export default class SoundPlayer extends Backbone.Model {

  initialize() {
    this.playSounds = soundEnabled && !!window.Audio
    if (!this.playSounds) {
      return
    }
    this.audio = new Audio("/assets/billiard-balls.mp3")
    this.listenForEvents()
  }

  listenForEvents() {
    this.listenTo(d, "move:success", () => {
      if (!this.playSounds) {
        return
      }
      this.audio.play()
    })
  }
}
