# TODO

- Show current playing song (use `vlc -I dummy --extraintf http --http-host localhost --http-port 9877 --http-password pass1234` backend, and then make an HTTP request to http://localhost:9877/requests/status.xml in order to obtain song information and update it every second; maybe regenerate a new password on every run) (alternatively, I can use backend `vlc -I rc` and call `info` to obtain song details, parsing the text after `now_playing:` .... can use `io = IO.popen('vlc -I rc http://radio.canstream.co.uk:8075/live.mp3', 'r+')` with `io.puts('inf')` and `io.gets` until all input is done; also use `Timeout::timeout(0.5) {}` to avoid timing out on `gets` when there is no more input)

- Radio menu Share menu item to share a radio station with others (displays or copies radio station name, language, URL, and rubio-radio URL)
