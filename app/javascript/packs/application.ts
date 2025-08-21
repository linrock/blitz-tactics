// This script runs on every page after DOM load

// FastClick is no longer needed in modern browsers
// Use CSS touch-action: manipulation instead

import SoundPlayer from '../components/sound_player'
import MiniChessboard from '../components/mini_chessboard'
import routes from '../routes'
import { BlitzConfig } from '../types'
import '../game_modes/base.sass'

const blitz: BlitzConfig = {};
(<any>window).blitz = blitz

document.addEventListener(`DOMContentLoaded`, () => {
  const { controller, action } = document.querySelector(`body`).dataset

  // initialize route components/views
  routes[`${controller}#${action}`]?.();

  // initialize all mini chessboards
  [].forEach.call(document.querySelectorAll(`.mini-chessboard`), (el: HTMLElement) => {
    const { fen, initialMove, initialMoveSan, flip, options } = el.dataset
    let optionsJson = {}
    if (options) {
      optionsJson = JSON.parse(options)
    }
    new MiniChessboard({
      el, fen, flip: flip === `true`,
      initialMove, initialMoveSan,
      ...optionsJson
    })
  })

  // initialize global views/components
  new SoundPlayer()

  // Modern browsers handle touch events properly with CSS touch-action
  // No need for FastClick.attach(document.body)
})
