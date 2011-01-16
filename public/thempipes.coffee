if window?
    $("#visualize").click () ->
        username = $("#lastfm_username").val()
        $.get("/gen204?username=" + username)
        if username == ""
            window.alert "Enter a username"
            return

        $("#visualize").fadeOut 500, () -> $("#throbber").fadeIn 500

        fetch_fave_artists username, (err, artists) ->
            if err?
                reset
                return alert "ERROR: " + err

            if artists.length == 0
                reset
                return alert "Sorry, there's no songs in your library."

            $("#wordle_input").val transform_to_wordle_string artists
            $("#wordle").submit()
        false

    reset = () ->
        $("#visualize").show
        $("#throbber").hide

# handle enter key hits on the textbox manually, because otherwise the form will submit to this page, and nothing will happen.
    $("#dummy").submit () =>
        $("#visualize").click()
        false # stop the default submit event

fetch_fave_artists = (username, callback) ->
    get_top_artists_page = (page, callback) ->
        ajax_data = {
            format: "json"
            api_key: "b5f4ec6308ea9378b9e82fbf7f3edf65"
            format: "json"
            method: "user.gettopartists"
            user: username
            page: page
        }
        $.ajax {
            url: "http://ws.audioscrobbler.com/2.0/"
            type: "get"
            data: ajax_data,
            success: (json) => callback(null, json)
            error: (xhr, errtype, e) => callback(errtype, null)
            dataType: "jsonp"
        }
    fetch_pages = (page_numbers, callback) => async_map page_numbers, get_top_artists_page, callback
    top_artists = []
    add_artists = (json_response) ->
        for artist in json_response.topartists.artist
            top_artists.push artist

    # get the first one
    get_top_artists_page 1, (err, json) ->
        metadata = json.topartists['@attr'] || json.topartists['#text']
        totalPages = metadata.totalPage

        if totalPages >= 1
            add_artists json

        if totalPages >= 2
            fetch_pages [2..totalPages], (err, jsons) ->
                if err?
                    return callback(err, null)
                add_artists json for json in jsons
                callback null, top_artists


transform_to_wordle_string = (artists) ->
    text_artists = for artist in artists
        # whitespace and colons are delimiters in wordle's input.
        # replace them with harmless (to wordle) tildes
        clean_name = artist.name.replace(/(\s|:)/g, "~")
        clean_name + ":" + artist.playcount

    return text = text_artists.join "\n"

# Map a function over an array, asynchronously.
# Calls 'callback(null, transformed_items)' when all mapping functions have returned.
# Calls 'callback(error, null)' when there's an error with any of the mapping functions.
#
# arr = the array to iterate over
# iterator = function(item, function callback(err, transformed_item))
# callback = function(err, transformed_items)
# if we get any errors, call the error callback and ignore subsequent returns.
async_map = (arr, iterator, callback) ->
    n_expected = arr.length
    n_results = 0
    results = []
    global_error = false
    for own value, key in arr
        do (value, key) ->
            iterator value, (err, result) ->
                if err?
                    global_error = true
                    return callback(err, null)
                if global_error
                    return # we've already called the error callback, just ignore.
                results[key] = result
                n_results += 1
                if n_results == arr.length
                    return callback(null, results)

test = () =>
    assert = require 'assert'
    start = [1, 2, 3]
    expected = [2, 3, 4]

    map_async start,
        (i, cb) => cb(null, i + 1),
        (err, result) =>
            assert.deepEqual(result, expected)
test() if not window?
