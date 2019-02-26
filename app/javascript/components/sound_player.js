import Backbone from 'backbone'

import { toggleSound } from '../api/requests'
import Listener from '../listener'
import { dispatch } from '../store'

const theme = `sfx`
const audioMap = {
  'move:sound': new Audio(`/sounds/${theme}/Move.mp3`),
  'move:fail': new Audio(`/sounds/${theme}/Check.mp3`),
  'puzzle:solved': new Audio(`/sounds/${theme}/Capture.mp3`),
}

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
    new Listener({
      'sound:enabled': enabled => {
        const el = this.volumeIconEl.querySelector(`use`)
        if (enabled) {
          el.setAttribute(`xlink:href`, `#volume-on`)
          this.loadSounds()
        } else {
          el.setAttribute(`xlink:href`, `#volume-off`)
        }
        toggleSound(enabled)
      }
    })
  }

  loadSounds() {
    if (this.soundsLoaded) {
      return
    }
    Object.values(audioMap).forEach(audio => audio.load())
    const eventMap = {}
    Object.keys(audioMap).forEach(event => {
      eventMap[event] = () => this.playSound(event)
    })
    new Listener(eventMap)
    this.soundsLoaded = true
  }

  playSound(type) {
    if (this.soundEnabled && audioMap[type].readyState >= 2) {
      audioMap[type].play()
    }
  }

  _toggleVolume() {
    this.soundEnabled = !this.soundEnabled
    dispatch(`sound:enabled`, this.soundEnabled)
  }
}
