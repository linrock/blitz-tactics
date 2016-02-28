//= require jquery
//= require jquery_ujs
//= require jquery-ui/draggable
//= require jquery-ui/droppable
//= require imagesloaded.pkgd
//= require underscore
//= require backbone
//= require chess
//= require_self
//= require_tree .


window.Views = {};
window.Models = {};

window.d = _.clone(Backbone.Events);
window.blitz = {};


$(function() {

  _.each(Views, function(view) { new view; });
  new Models.Puzzles;

});
