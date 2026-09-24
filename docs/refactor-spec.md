# Refactoring specification

## Goal
Improve maintainability of the platformer without changing gameplay behavior or breaking the LÖVE2D runtime model.

## Scope
This refactor covers the code paths that are currently hardest to maintain:
- global state and shared runtime references
- player responsibilities and gameplay logic
- map-driven entity creation and world setup
- screen/state transition structure

## Constraints
- Do not change core gameplay rules unless required to preserve behavior.
- Keep the project runnable in LÖVE2D after each incremental step.
- Prefer small, reversible refactors over large rewrites.
- Maintain backward compatibility with the existing asset and map pipeline.

## Target architecture
The target design should follow these principles:
1. Explicit dependency injection for runtime services.
2. Clear separation of concerns between state, world, entity, and asset layers.
3. Centralized game context for shared resources.
4. Smaller, focused modules instead of large monolithic update files.
5. Data-driven spawning and registry-based entity creation.

## Refactor focus areas

### 1. Shared runtime context
Create a single game context or app container that owns:
- assets
- settings
- score data
- current state
- audio references

This reduces implicit use of global Lua variables such as `sprite`, `hud`, `soundEvents`, and `mainTheme`.

### 2. Player decomposition
Split the responsibilities currently combined in `entity/Player.lua` into smaller components:
- input handling
- physics and collision
- combat and bullet management
- animation updates
- orchestration

The `Player` class should remain the gameplay-facing object but delegate specialized logic.

### 3. World and spawning
Improve entity creation in `World.lua` by:
- centralizing entity registration
- standardizing map-object spawn contracts
- moving spawn logic into dedicated helper functions
- keeping world lifecycle logic focused on update/draw and cleanup

### 4. State machine clarity
Simplify state transitions in `state/State.lua` by enforcing a consistent interface for all states:
- `enter`
- `update`
- `draw`
- `keypressed`
- `keyreleased`
- `leave`

This reduces hidden behavior and makes screen transitions easier to reason about.

### 5. Config and utilities
Move tuneable values and identifiers into clearer config modules instead of scattering them through gameplay logic.

## Acceptance criteria
The refactor is considered successful when:
- the game still starts and runs in LÖVE2D
- the gameplay flow remains unchanged
- global dependency usage has been reduced
- `Player` responsibilities are separated into smaller modules
- entity creation follows a cleaner registry-driven pattern
- the state machine is easier to extend

## Non-goals
- Full engine rewrite
- Large gameplay redesign
- Removing the Tiled map workflow
- Converting the project to a different framework or language

## Implementation philosophy
Use small, testable increments. Each stage should keep the project runnable. Avoid broad rewrites unless a file has become too coupled to support the next refactor step.
