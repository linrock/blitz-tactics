/* eslint no-console:0 */

import $ from 'jquery'
import _ from 'underscore'

import MiniBoard from '../views/mini_board'
import routes from '../routes'


window.d = _.clone(Backbone.Events);
window.blitz = {};
window.config = {
  comboSizeForNextLevel: 100
};

// Preload piece images
//
(function() {
  const colors = [ 'w', 'b' ];
  const pieces = [ 'k', 'q', 'r', 'b', 'n' ];
  for (let i in pieces) {
    for (let j in colors) {
      const img = new Image();
      img.src = `/assets/pieces/${colors[j] + pieces[i]}.png`;
    }
  }
})();

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

  $.ajaxPrefilter((options, originalOptions, xhr) => {
    if (!options.crossDomain) {
      const token =  $('meta[name=csrf-token]').attr('content')
      xhr.setRequestHeader('X-CSRF-Token', token)
    }
  })

  if (typeof route === 'function') {
    route()
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
      new MiniBoard({ el: $el, fen })
    } else if (options) {
      new MiniBoard(Object.assign({ el: $el }, options))
    }
  })
})
