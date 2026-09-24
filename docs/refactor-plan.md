# Refactoring plan

## Status
The project has already completed the key maintainability milestones in the current refactor branch:
- shared game context and runtime bootstrap cleanup
- player decomposition into input, physics, and combat modules
- world and entity dependency cleanup
- state-screen context consistency pass
- runtime config centralization

## Remaining follow-up work
The codebase is in a much healthier state, but a few refinements remain for long-term maintainability:
- extract animation handling from `Player` into a dedicated `PlayerAnimator` module
- create helper functions for map-object spawning to reduce `World:init` complexity
- standardize naming and comments across the remaining legacy files
- continue reducing late-stage global fallbacks once the game is fully validated in LÖVE2D

## Phase 1: Introduce a shared game context
### Objective
Remove direct, hidden reliance on Lua globals and centralize shared runtime state.

### Changes
- Add a `GameContext` or `App` container
- Move runtime references there:
  - assets
  - settings
  - score manager
  - audio objects
  - active state
- Pass context to `State`, `World`, and entity constructors

### Files likely involved
- `main.lua`
- `Global.lua`
- `state/State.lua`
- `World.lua`

### Validation
- Launch project in LÖVE2D
- Confirm startup, menu flow, and state transitions still work

---

## Phase 2: Decompose `Player`
### Objective
Split the monolithic player logic into smaller, specialized modules.

### Changes
- Extract input handling to `PlayerInput`
- Extract movement/collision to `PlayerPhysics`
- Extract combat and ammo logic to `PlayerCombat`
- Extract animation logic to `PlayerAnimator`
- Keep `Player` as an orchestrator and entity model

### Files likely involved
- `entity/Player.lua`
- `entity/Ammo.lua`
- `utils/Animation.lua`

### Validation
- Verify jump, run, shoot, wall collision, and damage behavior remain identical
- Repeat core gameplay loop manually in runtime

---

## Phase 3: Improve world/entity creation
### Objective
Reduce duplication and confusion in map-driven entity instantiation.

### Changes
- Add a single entity registry
- Move spawn parsing into helper functions
- Standardize entity constructor contract
- Keep world loading logic focused on lifecycle management

### Files likely involved
- `World.lua`
- `constants/EntityTypes.lua`
- `constants/EntityNames.lua`

### Validation
- Load each map and ensure all objects still spawn correctly
- Check current enemies and pickups still appear with same names/properties

---

## Phase 4: Formalize state interface
### Objective
Make state transitions more consistent and easier to maintain.

### Changes
- Define a common state lifecycle
- Ensure each state implements a consistent interface
- Move screen-specific behavior out of the state machine

### Files likely involved
- `state/State.lua`
- `state/MenuState.lua`
- `state/GameState.lua`
- `state/SettingsState.lua`
- other state files under `state/`

### Validation
- Confirm menu/navigation flow still works
- Ensure pause, exit, and state switching still work behaviorally

---

## Phase 5: Clean config and naming
### Objective
Reduce ambiguity and make new feature work easier to implement.

### Changes
- Separate gameplay constants from runtime logic
- Standardize naming conventions
- Move tuning values to config modules
- Remove stale or misleading comments

### Files likely involved
- `Global.lua`
- `constants/`
- `utils/`

### Validation
- Confirm no broken references after renames
- Ensure game still loads and plays normally

---

## Recommended execution order
1. Game context extraction
2. Player decomposition
3. World/entity registry cleanup
4. State interface cleanup
5. Naming and config normalization

## Risk management
- Do not refactor all files at once
- Keep each step incremental and verifiable
- After each phase, run the game and confirm the same features still work
- Revert if a step introduces hidden dependency issues

## Expected outcome
After completion, the project should be:
- easier to read
- easier to extend with new entities or screens
- less dependent on global state
- more predictable for future collaborators
