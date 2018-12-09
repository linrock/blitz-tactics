import FastClick from 'fastclick'
import MiniChessboard from '../components/chessboard/mini_chessboard.ts'
import routes from '../routes.ts'

interface BlitzConfig {
  levelPath?: string
  position?: object
  loggedIn?: boolean
}

const blitz: BlitzConfig = {};
(<any>window).blitz = blitz

document.addEventListener(`DOMContentLoaded`, () => {
  const { controller, action } = document.querySelector(`body`).dataset
  const route = routes[`${controller}#${action}`]

  // initialize route components/views
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

  FastClick.attach(document.body)
})
