import FastClick from 'fastclick'

import SoundPlayer from '../components/sound_player'
import MiniChessboard from '../components/chessboard/mini_chessboard'
import routes from '../routes'

interface BlitzConfig {
  levelPath?: string
  position?: object
  loggedIn?: boolean
}

const blitz: BlitzConfig = {};
(<any>window).blitz = blitz

document.addEventListener(`DOMContentLoaded`, () => {
  const { controller, action } = document.querySelector(`body`).dataset

  // initialize route components/views
  const route = routes[`${controller}#${action}`]
  if (typeof route !== `undefined`) {
    new route
  }

  // initialize all mini chessboards
  [].forEach.call(document.querySelectorAll(`.mini-chessboard`), el => {
    let { fen, initialMove, flip, options } = el.dataset
    if (options) {
      options = JSON.parse(options)
    }
    new MiniChessboard({ el, fen, flip: flip === `true`, initialMove, ...options })
  })

  // initialize global views/components
  new SoundPlayer()

  FastClick.attach(document.body)
})
