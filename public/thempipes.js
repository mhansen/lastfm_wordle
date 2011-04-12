(function() {
  var async_map, fetch_fave_artists, reset, test, transform_to_wordle_string;
  var __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };
  if (typeof window != "undefined" && window !== null) {
    $("#visualize").click(function() {
      var username;
      username = $("#lastfm_username").val();
      $.get("/gen204?username=" + username);
      if (username === "") {
        window.alert("Enter a username");
        return;
      }
      $("#visualize").fadeOut(200, function() {
        return $("#throbber").fadeIn(500);
      });
      fetch_fave_artists(username, function(err, artists) {
        if (err != null) {
          reset();
          return alert("ERROR: " + err);
        }
        if (artists.length === 0) {
          reset();
          return alert("Sorry, there's no songs in your library.");
        }
        $("#wordle_input").val(transform_to_wordle_string(artists));
        return $("#wordle").submit();
      });
      return false;
    });
    reset = function() {
      $("#visualize").stop();
      $("#throbber").stop();
      $("#throbber").fadeOut(200, function() {
        return $("#visualize").fadeIn(500);
      });
      return $("#lastfm_username").select();
    };
    $("#dummy").submit(__bind(function() {
      $("#visualize").click();
      return false;
    }, this));
  }
  fetch_fave_artists = function(username, callback) {
    var add_artists, fetch_pages, get_top_artists_page, top_artists;
    get_top_artists_page = function(page, callback) {
      var ajax_data;
      ajax_data = {
        format: "json",
        api_key: "b5f4ec6308ea9378b9e82fbf7f3edf65",
        format: "json",
        method: "user.gettopartists",
        user: username,
        page: page
      };
      return $.ajax({
        url: "http://ws.audioscrobbler.com/2.0/",
        type: "get",
        data: ajax_data,
        success: __bind(function(json) {
          return callback(null, json);
        }, this),
        error: __bind(function(xhr, errtype, e) {
          return callback(errtype, null);
        }, this),
        dataType: "jsonp"
      });
    };
    fetch_pages = __bind(function(page_numbers, callback) {
      return async_map(page_numbers, get_top_artists_page, callback);
    }, this);
    top_artists = [];
    add_artists = function(json_response) {
      var artist, _i, _len, _ref, _results;
      _ref = json_response.topartists.artist;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        artist = _ref[_i];
        _results.push(top_artists.push(artist));
      }
      return _results;
    };
    return get_top_artists_page(1, function(err, json) {
      var metadata, totalPages, _i, _results;
      metadata = json.topartists['@attr'] || json.topartists['#text'];
      totalPages = metadata.totalPages;
      if (totalPages >= 1) {
        add_artists(json);
      }
      if (totalPages >= 2) {
        return fetch_pages((function() {
          _results = [];
          for (var _i = 2; 2 <= totalPages ? _i <= totalPages : _i >= totalPages; 2 <= totalPages ? _i += 1 : _i -= 1){ _results.push(_i); }
          return _results;
        }).call(this), function(err, jsons) {
          var json, _i, _len;
          if (err != null) {
            return callback(err, null);
          }
          for (_i = 0, _len = jsons.length; _i < _len; _i++) {
            json = jsons[_i];
            add_artists(json);
          }
          return callback(null, top_artists);
        });
      } else {
        return callback(null, top_artists);
      }
    });
  };
  transform_to_wordle_string = function(artists) {
    var artist, clean_name, text, text_artists;
    text_artists = (function() {
      var _i, _len, _results;
      _results = [];
      for (_i = 0, _len = artists.length; _i < _len; _i++) {
        artist = artists[_i];
        clean_name = artist.name.replace(/(\s|:)/g, "~");
        _results.push(clean_name + ":" + artist.playcount);
      }
      return _results;
    })();
    return text = text_artists.join("\n");
  };
  async_map = function(arr, iterator, callback) {
    var global_error, key, n_expected, n_results, results, value, _len, _results;
    n_expected = arr.length;
    n_results = 0;
    results = [];
    global_error = false;
    _results = [];
    for (key = 0, _len = arr.length; key < _len; key++) {
      value = arr[key];
      _results.push((function(value, key) {
        return iterator(value, function(err, result) {
          if (err != null) {
            global_error = true;
            return callback(err, null);
          }
          if (global_error) {
            return;
          }
          results[key] = result;
          n_results += 1;
          if (n_results === arr.length) {
            return callback(null, results);
          }
        });
      })(value, key));
    }
    return _results;
  };
  test = __bind(function() {
    var assert, expected, start;
    assert = require('assert');
    start = [1, 2, 3];
    expected = [2, 3, 4];
    return async_map(start, __bind(function(i, cb) {
      return cb(null, i + 1);
    }, this), __bind(function(err, result) {
      return assert.deepEqual(result, expected);
    }, this));
  }, this);
  if (!(typeof window != "undefined" && window !== null)) {
    test();
  }
}).call(this);
