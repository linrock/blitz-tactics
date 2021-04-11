// This script runs on every page after DOM load

import FastClick from 'fastclick'

import SoundPlayer from './components/sound_player'
import MiniChessboard from './components/mini_chessboard'
import routes from './routes'
import { BlitzConfig } from './types'

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

  FastClick.attach(document.body)
})
