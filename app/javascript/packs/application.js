import MiniChessboard from '../components/chessboard/mini_chessboard'
import routes from '../routes'


window.blitz = {};
window.config = {
  comboSizeForNextLevel: 100
};

// Set meta viewport
//
(() => {
  const viewport = document.querySelector('meta[name="viewport"]'),
        isIphone = navigator.userAgent.match(/iPhone/i),
        setViewport = () => viewport.setAttribute('content', 'width=500, user-scalable=no')

  if (!isIphone) {
    return
  }
  setViewport()
  window.addEventListener('resize', () => {
    var w = window.innerWidth
    var h = window.innerHeight
    if (w > h) {
      viewport.removeAttribute('content')
    } else {
      setViewport()
    }
  }, true)
})()

document.addEventListener('DOMContentLoaded', () => {
  const { controller, action } = document.querySelector('body').dataset
  const route = routes[`${controller}#${action}`]

  // initialize route components/views
  if (typeof route !== 'undefined') {
    new route
  }
  if (blitz.route) {
    new routes[blitz.route]
  }

  // initialize all mini chessboards
  document.querySelectorAll('.mini-chessboard').forEach(el => {
    let { fen, initialMove, options } = el.dataset
    if (options) {
      options = JSON.parse(options)
    }
    new MiniChessboard({ el, fen, initialMove, ...options })
  })
})
