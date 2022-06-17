# rubio-radio
[![Gem Version](https://badge.fury.io/rb/rubio-radio.svg)](https://badge.fury.io/rb/rubio-radio)

![img](https://user-images.githubusercontent.com/5798442/171986696-24bedc38-3811-4c62-a5ad-89c09d015c8a.png)

:bowtie: Alpha

## Installation

### Requirements:

**[cvlc](https://github.com/videolan/vlc)**

Note that on the Mac, you do not get `cvlc` by default when installing [VLC](https://www.videolan.org/vlc/download-macosx.html), so you also have to do the following:

1- Create a `~/bin/cvlc` file with the following content:
```sh
#!/bin/sh

/Applications/VLC.app/Contents/MacOS/VLC -I rc $@
```

2- Run:
```
chmod +x ~/bin/cvlc
```

3- Add the following line to `~/.zprofile`, `~/.zshrc`, `~/.bash_profile`, `~/.profile`, or `~/.bashrc` depending on your system setup:
```sh
export PATH="$PATH:$HOME/bin"
```

### Ruby Gem:

```
gem install rubio-radio
```

## Usage

```
rubio
```

Default player is `cvlc`. But you can use any command line player that can take URL of radio station as its first argument.

```
rubio --backend mpg123
```

## LICENSE

MIT
