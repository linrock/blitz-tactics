// This script runs on every page after DOM load

import FastClick from 'fastclick'

import SoundPlayer from '@blitz/components/sound_player'
import MiniChessboard from '@blitz/components/chessboard/mini_chessboard'
import routes from '@blitz/routes'
import { BlitzConfig } from '@blitz/types'

const blitz: BlitzConfig = {};
(<any>window).blitz = blitz

document.addEventListener(`DOMContentLoaded`, () => {
  const { controller, action } = document.querySelector(`body`).dataset

  // initialize route components/views
  const route = routes[`${controller}#${action}`]
  if (typeof route !== `undefined`) {
    // @ts-ignore. TODO fix this
    new route
  }

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
