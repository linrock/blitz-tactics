import Backbone from 'backbone'

import Listener from '../../listener'

const soundEnabled = false

export default class SoundPlayer {

  constructor() {
    this.playSounds = soundEnabled && !!window.Audio
    if (!this.playSounds) {
      return
    }
    this.audio = new Audio(`/assets/piece-dropped.mp3`)
    this.listenForEvents()
  }

  listenForEvents() {
    new Listener({
      'move:success': () => this.audio.play()
    })
  }
}
