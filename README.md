# 2D Platformer

Simple 2D platformer written in [LÖVE](https://love2d.org)

## Features

- Custom spritesheet and animations
- Move, jump, shoot (remember to reload ammunition!)
- Different types of enemmies - bigger ones will chase you!
- Different obstacles - spikes, acid drops
- Moving platforms, spring platforms
- Top 10 scores
- Settings for Audio and VSync

## Screenshots

<p align="center">
  <img src="https://user-images.githubusercontent.com/5923943/108523469-3c929180-72ce-11eb-8dd5-38b7c5ce8edf.png" />
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/5923943/108523637-72d01100-72ce-11eb-9879-f23c7fca86fd.png" />
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/5923943/108524019-e2de9700-72ce-11eb-809a-57286c5e2219.png" />
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/5923943/108523515-4b794400-72ce-11eb-8e00-ee0e2767cbde.png" />
</p>

<p align="center">
  <img src="https://user-images.githubusercontent.com/5923943/108523557-5a5ff680-72ce-11eb-81d4-066140291c45.png" />
</p>

## Installation

- Clone the repository
- Run LÖVE in the project

```zsh
git clone https://github.com/WilsonDev/platformer.git
cd platformer
love .
```

## Tests

Run the player unit tests and deterministic gameplay scenarios with Lua:

```zsh
lua tests/player_test.lua
lua tests/gameplay_scenarios.lua
```

The gameplay scenarios cover state navigation, settings changes, entering a game,
score submission, and exit persistence without requiring an interactive window.

## TODO

- [ ] More levels

## Licensing

### Code

This code is licensed under the [MIT license](LICENSE.md). Check out the LICENSE file for more information.

### Assets

Unless mentioned otherwise, all art assets (files in ``resources/``) are distributed under the [Creative Commons Attribution 4.0 International](http://creativecommons.org/licenses/by/4.0/) license.


## Credits
- Music: Eric Skiff - Song Name - Underclocked - Available at http://ericskiff.com/music/
- Music: Eric Skiff - Song Name - Digital Native - Available at http://ericskiff.com/music/
- Fonts: [Visitor](https://www.dafont.com/visitor.font) by ÆNIGMA FONTS 
