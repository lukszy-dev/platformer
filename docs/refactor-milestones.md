# Refactoring milestone checklist

## Milestone 1: Stabilize the runtime bootstrap
### Goal
Reduce bootstrapping complexity and make startup dependencies explicit.

### Checklist
- [ ] Review all runtime globals used during startup in `main.lua`
- [ ] Identify which values are truly global application state
- [ ] Create a central `GameContext` or `App` container
- [ ] Move asset references into the context
- [ ] Move settings and score state into the context
- [ ] Update `main.lua` to initialize the context once
- [ ] Ensure `State` receives the context instead of using global state directly
- [ ] Validate that the game still starts and reaches the menu

### Definition of done
The game loads without relying on implicit Lua globals for shared runtime data.

---

## Milestone 2: Remove hidden dependencies from states
### Goal
Make transitions and state logic explicit and easier to debug.

### Checklist
- [ ] Review state methods in `state/State.lua`
- [ ] Define a consistent state lifecycle interface
- [ ] Document how states are initialized and switched
- [ ] Replace hidden global lookups with injected dependencies
- [ ] Confirm menu, settings, score screens still work
- [ ] Verify exit and return behavior still functions correctly

### Definition of done
State changes are explicit and do not depend on hidden runtime variables.

---

## Milestone 3: Break up `Player` responsibilities
### Goal
Decompose the oversized player object into smaller, purpose-specific modules.

### Checklist
- [ ] Identify all responsibilities currently handled by `entity/Player.lua`
- [ ] Extract input handling into a dedicated module
- [ ] Extract movement and collision logic into a dedicated module
- [ ] Extract shooting and ammo logic into a dedicated module
- [ ] Extract animation updates into a dedicated module
- [ ] Keep `Player` as a coordinator object
- [ ] Preserve all current movement and jump rules
- [ ] Preserve all current projectile and damage rules
- [ ] Confirm player still reacts the same way to keyboard input

### Definition of done
`Player` no longer mixes physics, input, animation, and combat responsibilities in one object.

---

## Milestone 4: Simplify world initialization logic
### Goal
Make world setup easier to trace and extend.

### Checklist
- [ ] Review `World:init` and object creation flow
- [ ] Identify all map object parsing responsibilities
- [ ] Create helper functions for entity spawning
- [ ] Centralize entity type registration
- [ ] Reduce ad hoc conditionals in world creation
- [ ] Ensure all entity names and types still map correctly
- [ ] Verify map loading still creates the same entities

### Definition of done
World setup is easier to follow and new entities can be added with less duplication.

---

## Milestone 5: Improve entity registry and spawn consistency
### Goal
Create a clearer, more predictable spawn model.

### Checklist
- [ ] Review all entity definitions under `entity/`
- [ ] Confirm naming conventions across entity classes
- [ ] Make spawn metadata consistent
- [ ] Centralize entity mapping in a registry
- [ ] Verify object properties are still respected
- [ ] Ensure enemies, pickups, platforms, and hazards spawn correctly

### Definition of done
Entity creation follows a single pattern and is easier to extend without touching multiple files.

---

## Milestone 6: Separate configuration from gameplay logic
### Goal
Reduce hardcoded tuning and improve code clarity.

### Checklist
- [ ] Locate magic numbers in gameplay classes
- [ ] Identify values that should be treated as configuration
- [ ] Move tuning values to config or constants modules
- [ ] Keep gameplay code focused on behavior rather than numbers
- [ ] Validate that movement balance remains unchanged

### Definition of done
Gameplay tuning values are organized and easier to adjust without editing logic.

---

## Milestone 7: Clean up naming and documentation
### Goal
Make the project easier to understand for future contributors.

### Checklist
- [ ] Review mixed-language comments and confusing names
- [ ] Standardize naming patterns across modules
- [ ] Update comments that describe stale or outdated behavior
- [ ] Add brief documentation to newly extracted modules
- [ ] Confirm the architecture matches the intended refactor design

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
