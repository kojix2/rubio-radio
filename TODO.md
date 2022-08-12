# TODO

- Provide option to remove `bookmark` support
- Fetch radio stations gradually to avoid making user wait for app to start
- View currently playing station (in case it got lost in filtering/pagination)


- Support OR-based FTS (Full-Text-Search) queries by treating multiple words as WORD1 OR WORD2, etc...
- Support exact FTS (Full-Text-Search) queries using double-quotes (e.g. "WORD1 WORD2")
- Support column-based queries by prefixing query term with column name + colon (e.g. "language:english"), which can be combined with FTS queries (e.g. "jazz language:english"). Also, there is no need to enter all of the column letters, yet only the first few letters that distinguish it from other columns (e.g. "jazz l:english")

- Make window margined and provide option to disable margins if preferred (`--no-margins`)

- Show current playing song (use `vlc -I dummy --extraintf http --http-host localhost --http-port 9877 --http-password pass1234` backend, and then make an HTTP request to http://localhost:9877/requests/status.xml in order to obtain song information and update it every second; maybe regenerate a new password on every run) (alternatively, I can use backend `vlc -I rc` and call `info` to obtain song details, parsing the text after `now_playing:` .... can use `io = IO.popen('vlc -I rc http://radio.canstream.co.uk:8075/live.mp3', 'r+')` with `io.puts('inf')` and `io.gets` until all input is done; also use `Timeout::timeout(0.5) {}` to avoid timing out on `gets` when there is no more input)
