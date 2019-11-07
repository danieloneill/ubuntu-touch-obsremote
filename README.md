# OBS Remote (Ubuntu Touch)

A basic remote control for OBS Studio via obs-websocket for Ubuntu Touch

![Screenshot](https://i.imgur.com/rN3Ux7O.png)

## License

Copyright (C) 2019  Daniel O'Neill

This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License version 3, as published
by the Free Software Foundation.

This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranties of MERCHANTABILITY, SATISFACTORY QUALITY, or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.


## Installation
Well, the first thing you need is to grab the [obs-websocket plugin](https://github.com/Palakis/obs-websocket) and get that all working and set up.

To build this app, use the standard "clickable" method. (Plug your Ubuntu Touch device in, enable Developer Mode, and run "clickable" in the source directory of this project. It'll build, install, and launch this app.)

## Usage
Specify the websocket host path, and a password (if configured) and then connect to OBS by sliding the "active" switch to On.

When you want to stream, slide the "Stream" switch to On.

You can select scenes by simply tapping the scene name in the list.

At the bottom, various statistics about the system and stream are provided.

The "0/xxxx dropped" is how many frames were dropped out of total frames sent. The number on the RIGHT are successful. The number on the LEFT is a count of dropped frames.

## TODO
It's kinda dumb if it gets disconnected, or if you actively disconnect mid-stream.

Volume sliders would be convenient. It's very possible to implement, I just didn't need them, so I didn't implement them.

Really, having it laid out like OBS studio would be ideal, using a PageStack or similar. It's in there, but there's only one Page since it all fits on a single page already.

