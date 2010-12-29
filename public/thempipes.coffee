$("#submit").click () =>
    data = { lastfm_username : $("#lastfm_username").val() }
    $.get "/user", data, (artists) =>
        $("#wordle_input").val artists
        $("#wordle").submit()
    false
