import Backbone from 'backbone'

import Listener from '../listener'
import d from '../dispatcher'

export default class SoundPlayer extends Backbone.View {

  get events() {
    return {
      "click .volume-toggle": "_toggleVolume",
    }
  }

  get el() {
    return document.querySelector(`.main-header`)
  }

  initialize() {
    this.volumeIconEl = this.el.querySelector(`.volume-toggle`)
    this.soundEnabled = this.volumeIconEl.dataset.enabled == `true`
    this.playSounds = this.soundEnabled && !!window.Audio
    if (this.playSounds) {
      this.loadSounds()
    }
  }

  loadSounds() {
    if (this.soundsLoaded) {
      return
    }
    this.theme = `sfx`
    this.audioMap = {
      'move:make': new Audio(`/sounds/${this.theme}/move.ogg`),
      'move:fail': new Audio(`/sounds/${this.theme}/low_time.ogg`),
      'puzzle:solved': new Audio(`/sounds/${this.theme}/capture.ogg`),
    }
    Object.values(this.audioMap).forEach(audio => audio.load())
    const eventMap = {}
    Object.keys(this.audioMap).forEach(event => {
      eventMap[event] = () => this.playSound(event)
    })
    new Listener(eventMap)
    new Listener({
      'sound:enabled': enabled => {
        const el = this.volumeIconEl.querySelector(`use`)
        if (enabled) {
          el.setAttribute(`xlink:href`, `#volume-on`)
          this.loadSounds()
        } else {
          el.setAttribute(`xlink:href`, `#volume-off`)
        }
      }
    })
    this.soundsLoaded = true
  }

  playSound(type) {
    if (this.soundEnabled && this.audioMap[type].readyState === 4) {
      this.audioMap[type].play()
    }
  }

  _toggleVolume() {
    this.soundEnabled = !this.soundEnabled
    d.trigger(`sound:enabled`, this.soundEnabled)
  }
}
