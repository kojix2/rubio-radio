# Change Log

## 0.0.4

- Upgrade to glimmer-dsl-libui v0.5.17
- Replace `table` with new `refined_table` having pagination and filtering support across all columns (including language column)
- Request the top 10,000 radio stations upon starting the app
- Command option `--count` for configuring count of top radio stations (`10_000` by default)
- Command option `--per-page` for number of rows per page to display
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
