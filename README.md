# GEA - Godot Easy Audio 🎵🔊🚀
GEA (Godot Easy Audio) is a simple and powerful addon for the Godot Engine that enhances audio management by providing an easy way to handle music, sound effects, and transitions.
With GEA, you can smoothly fade, crossfade, and control audio playback effortlessly. 🎯🛠️🚀


## 🌟 Features
* 🎶 **Music Management**: Play, stop, pause, and crossfade between tracks.
* 🔊 **Sound Effects System**: Load and play sound effects efficiently with caching.
* ⚙️ **Customizable Settings**: Adjust volume, pitch, persistence, and playback speed.
* 🔄 **Seamless Integration**: Built on AudioStreamPlayer with extended capabilities.
* 📡 **Signal-Based Events**: Detect when sounds finish or transitions complete.


## 📥 Installation
1. Download or Clone the repository.
2. Place the `addons/` folder inside your Godot project.
3. Enable the plugin in `Project > Project Settings > Plugins`.


## ⚙️ Configuration
1. Go to `Project > Project Settings > Godot Easy > Audio`.
2. Customize the addon's behaviour as you like.
3. You're all set! ✅🎉


## 🚀 Getting Started

### Playing Music
```
Audio.play_music("res://audio/background.ogg")
```

### Crossfading Music
```
Audio.fade_music_to("res://audio/battle.ogg", Audio.MusicFadeTypes.CROSS_FADE, 2.0)
```

### Playing Sound Effects
```
Audio.play_sfx("res://audio/jump.wav")
```

### Preloading Sound Effects
```
Audio.load_sfx("jump", "res://audio/jump.wav")
Audio.play_sfx("jump")
```


## 📖 Documentation
For full documentation, visit the Wiki.


## 🤝 Contributing
We welcome contributions! Feel free to open issues or submit pull requests.


## 📜 License
This project is licensed under the MIT License.

---
Enhance your game’s audio experience with GEA - Godot Easy Audio! 🎧🔥
