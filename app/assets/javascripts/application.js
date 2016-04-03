//= require jquery
//= require jquery_ujs
//= require jquery-ui/draggable
//= require jquery-ui/droppable
//= require jquery-ui/sortable
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
window.config = {
  comboSizeForNextLevel: 100
};


// Preload piece images
//
(function() {
  var colors = [ "w", "b" ];
  var pieces = [ "k", "q", "r", "b", "n" ];

  for (var i in pieces) {
    for (var j in colors) {
      var img = new Image();
      img.src = "/assets/pieces/" + colors[j] + pieces[i] + ".png";
    }
  }

})();


$(function() {

  _.each(Views, function(view) { new view; });
  new Models.Puzzles;
  new Models.Notifier;

});
