# Change Log

## 0.0.6

- Command option `--[no-]margins` to show/hide margins around window content
- Update command option `--count` to accept `-1` as a valid value for fetching all radio stations
- Make app fetch all radio stations by default (`--count -1`)

## 0.0.5

- Upgrade to glimmer-dsl-libui v0.5.22
- Add/Remove currently playing radio station to bookmarks (remembered across app restarts by storing station UUID in a YAML file locally)
- View menu with "All", "Bookmarks", and "Playing" View menu items
- Command option `--[no-]bookmarks` to show/hide bookmarks in table
- Command option `--[no-]gradual` to load radio stations gradually (preventing user from waiting for app to start) or avoid loading gradually
- Support AND-based filtering with multiple words separated by space treated as WORD1 AND WORD2, ...
- Support exact term filtering with double-quoted filter term (e.g. "WORD1 WORD2")
- Support column-based filtering by prefixing a query term with column name + colon (e.g. "language:english"), which can be combined with other words (e.g. "jazz language:english"). Also, there is no need to enter all of the column letters, yet only the first few letters that distinguish it from other columns (e.g. "jazz l:english")

## 0.0.4

- Upgrade to glimmer-dsl-libui v0.5.18
- Replace `table` with new `refined_table` having pagination and filtering support across all columns (including language column)
- Request the top 10,000 radio stations upon starting the app
- Command option `--count` for configuring count of top radio stations (`10_000` by default)
- Command option `--per-page` for number of rows per page to display
- Command option `--page-count` for displaying page count ("of PAGE_COUNT pages")
- Command option `--width` for initial window width
- Command option `--height` for initial window height
- Command option `--no-menu` to remove the top menu bar and save screen space when not needed (on Mac it is always on because the menu bar does not take application screen space)
- Help menu About menu item to display message box with application license
- If `--per-page` is specified and `--height` is not specified, attempt to calculate intial window height for each platform automatically based on number of rows per page

## 0.0.3

- Fix bug

## 0.0.2

- Support Mac and Windows

## 0.0.1

- Initial implementation of rubio-radio
