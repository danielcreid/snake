# Snake

A Godot project built as a self-directed game prototype focused on learning by building a complete playable loop from the ground up. I chose Snake because it offers a clear set of rules and a tight scope, which made it a practical way to work through core systems without getting lost in feature creep.

## What this project is

This is a small Snake game with:

- directional movement and collision rules
- food spawning and snake growth
- score tracking and increasing speed over time
- start, pause, and game-over states
- custom artwork and sprite work created as part of the project

## Why I made it

I wanted a project that would force me to work through the full game development process: scene setup, input, gameplay logic, UI, state management, and visual design. I also wanted to explore creating my own pixel art and sprite animations in Aseprite, rather than relying on placeholder assets.

## What I set out to accomplish

- build a finished, playable game in Godot
- learn GDScript and scene-based architecture in practice
- design a simple but polished player experience
- create custom art assets that fit the game’s tone and style
- treat the project as a focused learning exercise with clear constraints

## Requirements

- Godot 4.7 or later

## Running the project

1. Open the project in Godot.
2. Open `project.godot`.
3. Press F5 or click Run.

## Project structure

- `src/gameplay/` — movement, spawning, score, and gameplay logic
- `src/menus/` — start, pause, and game-over screens
- `src/autoloads/` — shared game state
- `assets/` — visual assets and environment art

