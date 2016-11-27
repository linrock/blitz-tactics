// Initialize views depending on the page
//
$(function() {

  blitz.routes = {

    "levels#show": function() {
      initInterfaceBase();
      new Views.ProgressBar;
      new Views.Timer;
      new Views.LevelIndicator;
      new Views.Background;

      new Services.Puzzles;
      new Services.Notifier;
      new Services.LevelProgress;
    },

    "home#index": function() {
      initInterfaceBase();
      new Views.ProgressBar;
      new Views.Timer;
      new Views.LevelIndicator;
      new Views.Background;
      new Views.Onboarding;

      new Services.Puzzles({ source: "/level-1" });
      new Services.Notifier;
      new Services.LevelProgress;
    },

    "levels#edit": function() {
      new Views.LevelEditor;
    },

    "puzzles#show": function() {
      initInterfaceBase();

      new Services.Puzzles;
    },

    "static#positions": function() {
      new Experiments.PositionCreator();
    },

    "static#position": function() {
      new Views.Chessboard;
      new Views.MainHeader;
      new Views.MoveStatus;
      new Views.PiecePromotionModal;

      new Experiments.PositionTrainer();
    },

    "positions#show": function() {
      new Views.Chessboard;
      new Views.MainHeader;
      new Views.MoveStatus;
      new Views.PiecePromotionModal;

      new Experiments.PositionTrainer();
    },

    "positions#new": function() {
      new Views.Chessboard;
      new Experiments.PositionEditor();
    },

    "positions#edit": function() {
      new Views.Chessboard;
      new Experiments.PositionEditor();
    }

  };

  var initInterfaceBase = function() {
    new Views.ComboCounter;
    new Views.Chessboard;
    new Views.Instructions;
    new Views.MainHeader;
    new Views.MoveStatus;
    new Views.PiecePromotionModal;
    new Views.PuzzleCounter;
    new Views.PuzzleHint;

    new Services.SoundPlayer;
  };


  var pageKey = $("body").data("controller") + "#" + $("body").data("action");

  if (typeof blitz.routes[pageKey] === "function") {
    blitz.routes[pageKey]();
  }

});
