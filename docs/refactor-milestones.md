# Refactoring milestone checklist

## Milestone 1: Stabilize the runtime bootstrap
### Goal
Reduce bootstrapping complexity and make startup dependencies explicit.

### Checklist
- [x] Review all runtime globals used during startup in `main.lua`
- [x] Identify which values are truly global application state
- [x] Create a central `GameContext` or `App` container
- [x] Move asset references into the context
- [x] Move settings and score state into the context
- [x] Update `main.lua` to initialize the context once
- [x] Ensure `State` receives the context instead of using global state directly
- [x] Validate that the game still starts and reaches the menu

### Definition of done
The game loads without relying on implicit Lua globals for shared runtime data.

---

## Milestone 2: Remove hidden dependencies from states
### Goal
Make transitions and state logic explicit and easier to debug.

### Checklist
- [x] Review state methods in `state/State.lua`
- [x] Define a consistent state lifecycle interface
- [x] Document how states are initialized and switched
- [x] Replace hidden global lookups with injected dependencies
- [x] Confirm menu, settings, score screens still work
- [x] Verify exit and return behavior still functions correctly

### Definition of done
State changes are explicit and do not depend on hidden runtime variables.

---

## Milestone 3: Break up `Player` responsibilities
### Goal
Decompose the oversized player object into smaller, purpose-specific modules.

### Checklist
- [x] Identify all responsibilities currently handled by `entity/Player.lua`
- [x] Extract input handling into a dedicated module
- [x] Extract movement and collision logic into a dedicated module
- [x] Extract shooting and ammo logic into a dedicated module
- [x] Extract animation updates into a dedicated module
- [x] Keep `Player` as a coordinator object
- [x] Preserve all current movement and jump rules
- [x] Preserve all current projectile and damage rules
- [x] Confirm player still reacts the same way to keyboard input

### Definition of done
`Player` no longer mixes physics, input, animation, and combat responsibilities in one object.

---

## Milestone 4: Simplify world initialization logic
### Goal
Make world setup easier to trace and extend.

### Checklist
- [x] Review `World:init` and object creation flow
- [x] Identify all map object parsing responsibilities
- [x] Create helper functions for entity spawning
- [x] Centralize entity type registration
- [x] Reduce ad hoc conditionals in world creation
- [x] Ensure all entity names and types still map correctly
- [x] Verify map loading still creates the same entities

### Definition of done
World setup is easier to follow and new entities can be added with less duplication.

---

## Milestone 5: Improve entity registry and spawn consistency
### Goal
Create a clearer, more predictable spawn model.

### Checklist
- [x] Review all entity definitions under `entity/`
- [x] Confirm naming conventions across entity classes
- [x] Make spawn metadata consistent
- [x] Centralize entity mapping in a registry
- [x] Verify object properties are still respected
- [x] Ensure enemies, pickups, platforms, and hazards spawn correctly

### Definition of done
Entity creation follows a single pattern and is easier to extend without touching multiple files.

---

## Milestone 6: Separate configuration from gameplay logic
### Goal
Reduce hardcoded tuning and improve code clarity.

### Checklist
- [x] Locate magic numbers in gameplay classes
- [x] Identify values that should be treated as configuration
- [x] Move tuning values to config or constants modules
- [x] Keep gameplay code focused on behavior rather than numbers
- [x] Validate that movement balance remains unchanged

### Definition of done
Gameplay tuning values are organized and easier to adjust without editing logic.

---

## Milestone 7: Clean up naming and documentation
### Goal
Make the project easier to understand for future contributors.

### Checklist
- [x] Review mixed-language comments and confusing names
- [x] Standardize naming patterns across modules
- [x] Update comments that describe stale or outdated behavior
- [x] Add brief documentation to newly extracted modules
- [x] Confirm the architecture matches the intended refactor design

### Definition of done
The project is easier to navigate and understand without reading every file in full.

---

## Milestone 8: Final validation sweep
### Goal
Confirm the refactor preserved gameplay behavior and project viability.

### Checklist
- [ ] Run the game after each milestone
- [ ] Test menu navigation
- [ ] Test start of level and gameplay loop
- [ ] Test player movement and jumping
- [ ] Test shooting and enemy damage
- [ ] Test level transitions and death/end state
- [ ] Confirm saving/loading of settings and scores still works
- [ ] Check for obvious regressions or broken imports

### Definition of done
The project remains runnable and functionally equivalent to the pre-refactor state.

---

## Recommended order of execution
1. Milestone 1: Stabilize runtime bootstrap
2. Milestone 2: Remove hidden dependencies from states
3. Milestone 3: Break up `Player`
4. Milestone 4: Simplify world initialization
5. Milestone 5: Improve entity registry and spawn consistency
6. Milestone 6: Separate configuration from gameplay logic
7. Milestone 7: Clean up naming and documentation
8. Milestone 8: Final validation sweep

## Notes
- Each milestone should be completed as a small, isolated refactor.
- The project should remain playable after each milestone.
- If a milestone causes instability, pause and fix the root cause before continuing.
