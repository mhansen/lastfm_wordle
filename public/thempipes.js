(function() {
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  $("#submit").click(__bind(function() {
    var data;
    data = {
      lastfm_username: $("#lastfm_username").val()
    };
    $.get("/user", data, __bind(function(artists) {
      $("#wordle_input").val(artists);
      return $("#wordle").submit();
    }, this));
    return false;
  }, this));
}).call(this);
