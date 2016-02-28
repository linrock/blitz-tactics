//= require jquery
//= require jquery_ujs
//= require jquery-ui/draggable
//= require jquery-ui/droppable
//= require underscore
//= require backbone
//= require chess
//= require_self
//= require_tree .


window.Views = {};
window.Models = {};

window.d = _.clone(Backbone.Events);

$(function() {

  new Views.Chessboard;
  new Views.PiecePromotionModal;
  new Views.StartButton;
  new Views.PuzzleCounter;
  new Views.ComboMeter;
  new Views.MoveStatus;
  new Views.Timer;
  new Views.Solution;

  new Models.Puzzles;

});
