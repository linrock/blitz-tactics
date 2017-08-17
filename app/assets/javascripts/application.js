//= require jquery
//= require jquery_ujs
//= require jquery-ui/widgets/draggable
//= require jquery-ui/widgets/droppable
//= require jquery-ui/widgets/sortable
//= require imagesloaded.pkgd
//= require underscore
//= require backbone
//= require mousetrap
//= require chess
//= require_self
//= require_tree .
//= require routes


window.Views = {};
window.Models = {};
window.Services = {};
window.Experiments = {};

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
