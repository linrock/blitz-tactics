/* eslint no-console:0 */

import $ from 'jquery'
import _ from 'underscore'

import Background from '../views/background'
import Chessboard from '../views/chessboard'
import ComboCounter from '../views/combo_counter'
import Instructions from '../views/instructions'
import LevelEditor from '../views/level_editor'
import LevelIndicator from '../views/level_indicator'
import MainHeader from '../views/main_header'
import MiniBoard from '../views/mini_board'
import MoveStatus from '../views/move_status'
import Onboarding from '../views/onboarding'
import PiecePromotionModal from '../views/piece_promotion_modal'
import ProgressBar from '../views/progress_bar'
import PuzzleCounter from '../views/puzzle_counter'
import PuzzleHint from '../views/puzzle_hint'
import Timer from '../views/timer'

import PositionEditor from '../experiments/position_editor'
import PositionTrainer from '../experiments/position_trainer'
import PositionCreator from '../experiments/position_creator'

import Puzzles from '../models/puzzles'
import Notifier from '../models/notifier'
import LevelProgress from '../models/level_progress'
import SoundPlayer from '../models/sound_player'


window.d = _.clone(Backbone.Events);
window.blitz = {};
window.config = {
  comboSizeForNextLevel: 100
};

// Preload piece images
//
(function() {
  const colors = [ "w", "b" ];
  const pieces = [ "k", "q", "r", "b", "n" ];

  for (let i in pieces) {
    for (let j in colors) {
      const img = new Image();
      img.src = "/assets/pieces/" + colors[j] + pieces[i] + ".png";
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
    $viewport.attr("content", "width=500; user-scalable=no;");

    $w.on('resize', function(e) {
      var w = $w.width();
      var h = $w.height();
      if (w > h) {
        $viewport.removeAttr("content");
      } else {
        $viewport.attr("content", "width=500; user-scalable=no;");
      }
    });
  }
})();

const routes = {
  "levels#show": function() {
    initInterfaceBase()
    new ProgressBar
    new Timer
    new LevelIndicator
    new Background

    new Puzzles
    new Notifier
    new LevelProgress
  },

  "home#index": function() {
    initInterfaceBase()
    new ProgressBar
    new Timer
    new LevelIndicator
    new Background
    new Onboarding

    new Puzzles({ source: "/level-1" })
    new Notifier
    new LevelProgress
  },

  "levels#edit": function() {
    new LevelEditor
  },

  "puzzles#show": function() {
    initInterfaceBase()

    new Puzzles
  },

  "static#positions": function() {
    new PositionCreator()
  },

  "static#position": function() {
    new Chessboard
    new MainHeader
    new MoveStatus
    new PiecePromotionModal

    new PositionTrainer()
  },

  "positions#show": function() {
    new Chessboard
    new MainHeader
    new MoveStatus
    new PiecePromotionModal

    new PositionTrainer
  },

  "positions#new": function() {
    new Chessboard
    new PositionEditor
  },

  "positions#edit": function() {
    new Chessboard
    new PositionEditor
  }
}

var initInterfaceBase = function() {
  new ComboCounter
  new Chessboard
  new Instructions
  new MainHeader
  new MoveStatus
  new PiecePromotionModal
  new PuzzleCounter
  new PuzzleHint

  new SoundPlayer
}

// document.addEventListener('DOMContentLoaded', () => {
$(function() {
  const pageKey = $("body").data("controller") + "#" + $("body").data("action")
  const route = routes[pageKey]

  $.ajaxPrefilter((options, originalOptions, xhr) => {
    if (!options.crossDomain) {
      const token =  $('meta[name=csrf-token]').attr('content')
      xhr.setRequestHeader('X-CSRF-Token', token)
    }
  })

  if (typeof route === "function") {
    route()
  }
  if (blitz.route) {
    new routes[blitz.route]
  }

  $(".mini-chessboard").each((i, el) => {
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
