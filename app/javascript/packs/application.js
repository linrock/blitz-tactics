import $ from 'jquery'

import MiniChessboard from '../views/mini_chessboard'
import routes from '../routes'


window.blitz = {};
window.config = {
  comboSizeForNextLevel: 100
};

// Set meta viewport
//
(function() {
  var $viewport = $('meta[name="viewport"]'),
      $w = $(window);

  var isIphone = navigator.userAgent.match(/iPhone/i);

  if (isIphone) {
    $viewport.attr('content', 'width=500, user-scalable=no');
    $w.on('resize', function(e) {
      var w = $w.width();
      var h = $w.height();
      if (w > h) {
        $viewport.removeAttr('content');
      } else {
        $viewport.attr('content', 'width=500, user-scalable=no');
      }
    });
  }
})();

document.addEventListener('DOMContentLoaded', () => {
  const $body = $('body')
  const pageKey = `${$body.data('controller')}#${$body.data('action')}`
  const route = routes[pageKey]

  // initialize route components/views
  if (typeof route !== 'undefined') {
    new route
  }
  if (blitz.route) {
    new routes[blitz.route]
  }

  // initialize all mini chessboards
  $('.mini-chessboard').each((i, el) => {
    const $el = $(el)
    const fen = $el.data('fen')
    const options = $el.data('options')
    if (fen) {
      new MiniChessboard({ el: $el, fen })
    } else if (options) {
      new MiniChessboard(Object.assign({ el: $el }, options))
    }
  })
})
