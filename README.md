# OBS Studio Settings

A collection of my OBS Studio configuration files and settings.

## Contents

- Scene collections
- Profiles
- Plugin configurations

## Installation

1. Clone the repo
2. Copy to your OBS config directory
   - Setup specifically for OBS Studio installed via [Scoop](https://scoop.sh/)
3. Update all file paths to match your system (see Required Changes below)
4. Restart OBS Studio
5. Select the **MainProfile** profile (Profile menu → MainProfile)

## Required Changes

Before using these settings, you must update the following paths:

- **Python install**: Configure within OBS Scripts menu
- **Desktop scene sounds**: Change sounds folder location to `scripts\audio-files`
- **Warning/error screen**: Update batch runner file path in Advanced-Scene-Switcher Notifier Macro to `scripts\advanced-scene-switcher-scripts`
- **OBS Task Scheduler**: Update `scripts\task-scheduler\OBS-Task.bat` to your OBS installation location
- **Recording paths**: Set your preferred recording output locations

## Settings Overview

### Video Settings
- Optimized replay buffer/recording for RTX 3070
- Automatic switching to Game Capture scene

### Audio Settings
- Splits audio into 3 separate channels (Game, Discord, Microphone)

## Notes

Adjust settings based on your hardware and file paths.

## License

Feel free to use and modify these settings.