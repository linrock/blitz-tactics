import FastClick from 'fastclick'
import MiniChessboard from '../components/chessboard/mini_chessboard'
import routes from '../routes'

window.blitz = {};

document.addEventListener(`DOMContentLoaded`, () => {
  const { controller, action } = document.querySelector(`body`).dataset
  const route = routes[`${controller}#${action}`]

  // initialize route components/views
  if (typeof route !== `undefined`) {
    new route
  }

  // initialize all mini chessboards
  document.querySelectorAll(`.mini-chessboard`).forEach(el => {
    let { fen, initialMove, options } = el.dataset
    if (options) {
      options = JSON.parse(options)
    }
    new MiniChessboard({ el, fen, initialMove, ...options })
  })

  FastClick.attach(document.body)
})
