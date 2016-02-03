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
window.d = _.clone(Backbone.Events);

$(function() {

  new Views.Chessboard;
  new Views.Puzzles;
  new Views.StartButton;
  new Views.PuzzleCounter;
  new Views.Timer;

});
