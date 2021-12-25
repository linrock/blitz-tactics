import { toggleSound } from '../api/requests'
import { dispatch, subscribe } from '../events'

const theme = 'sfx'
const supportsAudio = !!(<any>window).Audio

let audioMap: Record<string, HTMLAudioElement> = {}
if (supportsAudio) {
  audioMap = {
    'move:sound': new Audio(`/sounds/${theme}/Move.mp3`),
    'move:fail': new Audio(`/sounds/${theme}/Check.mp3`),
    'puzzle:solved': new Audio(`/sounds/${theme}/Capture.mp3`),
  }
}

export default class SoundPlayer {
  private volumeIconEl: HTMLElement
  private soundEnabled = false
  private soundsLoaded = false
  private playSounds = false

  get el(): HTMLElement {
    return document.querySelector(`.main-header`)
  }

  constructor() {
    this.volumeIconEl = this.el.querySelector(`.volume-toggle`)
    this.soundEnabled = this.volumeIconEl.dataset.enabled == `true`
    this.playSounds = this.soundEnabled && supportsAudio
    if (this.playSounds) {
      this.loadSounds()
    }
    this.volumeIconEl.addEventListener('click', () => {
      // click the sound/volume icon in the main header to toggle sound on/off
      this.soundEnabled = !this.soundEnabled
      dispatch(`sound:enabled`, this.soundEnabled)
    });
    subscribe({
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

  private loadSounds() {
    if (this.soundsLoaded) {
      return
    }
    Object.values(audioMap).forEach((audio: HTMLAudioElement) => audio.load())
    const eventMap = {}
    Object.keys(audioMap).forEach(event => {
      eventMap[event] = () => this.playSound(event)
    })
    subscribe(eventMap)
    this.soundsLoaded = true
  }

  private playSound(type) {
    if (this.soundEnabled && audioMap[type].readyState >= 2) {
      audioMap[type].play().catch(e => {})
    }
  }
}
