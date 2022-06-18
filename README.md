# rubio-radio
[![Gem Version](https://badge.fury.io/rb/rubio-radio.svg)](https://badge.fury.io/rb/rubio-radio)

![img](https://user-images.githubusercontent.com/5798442/171986696-24bedc38-3811-4c62-a5ad-89c09d015c8a.png)

:bowtie: Alpha

## Installation

### Requirements:

**[VLC](https://github.com/videolan/vlc)**

`rubio` uses the `cvlc` command on Linux and `vlc -I rc` on Mac and Windows as the audio playback backend.

On Mac, it is recommended that you install VLC via [Homebrew](https://brew.sh/) to ensure the `vlc` command is added to the PATH environment variable automatically:

```
brew install vlc
```

On Windows, install VLC using the [Windows installer](https://www.videolan.org/vlc/download-windows.html), and then add the installed VLC app directory to the PATH environment variable (e.g. `C:\Program Files (x86)\VideoLAN\VLC`) to make the `vlc` command available.

### Ruby Gem:

```
gem install rubio-radio
```

## Usage

```
rubio
```

Default player is `cvlc` on Linux and `vlc -I rc` on Mac and Windows. But, you can use any command line player that can take URL of radio station as its first argument.

```
rubio --backend mpg123
```

## LICENSE

MIT
