# FractalClock Saver

This is a mac screensaver based on [HackerPoet/FractalClock](https://github.com/HackerPoet/FractalClock) ([video link](https://www.youtube.com/watch?v=4SH_-YhN15A)). 

It is built for macOS 10.14 Mojave and above, and has the following configuration options:

|           Option | Description                                                  | Default              |
| ---------------: | ------------------------------------------------------------ | -------------------- |
|    Fractal Depth | How deep the fractal is rendered. Higher values increase the detail of the fractal, but make the rendering slower. | 8                    |
|     Fractal Type | The hands which contribute to the fractal. This changes the hands from which the fractal branches and the hands displayed in the branches | Hour, Minute, Second |
| Show second hand | Whether to show the second hand of the clock. This locks the fractal type to \`Hour, Minute\` | True                 |

If you mess up with the fractal depth and lag the screensaver beyond repair, the defaults plist is located in `~/Library/Containers/com.apple.ScreenSaver.Engine.legacyScreenSaver/Data/Library/Preferences/ByHost`, the filename starting with `com.mrcat.FractalClock`. The fractal depth key is `FCFractalDepth`.