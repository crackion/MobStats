# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

MobStats is a Vanilla WoW 1.12.1 and Turtle WoW addon that displays mob statistics in human-friendly form in game tooltips. The addon is written in Lua and follows a Domain-Driven Design architecture.

## Architecture

The codebase is organized into distinct layers:

- **Boot.lua**: Entry point that sets up the global MobStats namespace with environment isolation
- **Infrastructure/**: Contains GameAPI.lua which wraps WoW's native API functions for unit information
- **Domain/**: Value objects for game concepts (Armor, Damage, Melee, MobLevel, Resistance)
- **Application/**: ApplicationService that orchestrates domain logic and data transformation
- **Presentation/**: UI layer with TooltipController, TooltipInterface, and specialized Drawers for different stat types

## Key Components

- **ApplicationService**: Central orchestrator that fetches raw game data via GameAPI, converts it to domain objects, and returns DTOs for presentation
- **GameAPI**: Infrastructure layer that wraps WoW's UnitResistance, UnitLevel, UnitDamage, etc. APIs
- **Domain Value Objects**: Immutable objects with business logic (e.g., ArmorVO calculates damage reduction percentages)
- **Tooltip System**: Hooks into GameTooltip's OnShow event to inject mob stats when mousing over enemies

## File Loading Order

The MobStats.toc file defines the exact loading order of Lua files, which is critical for proper initialization.

## Environment Isolation

All files use `setfenv(1, MobStats)` to work within the addon's isolated namespace rather than the global WoW environment.

## Type Annotations

The codebase uses EmmyLua-style type annotations extensively for development tooling support.

## Testing

The project includes a comprehensive test suite using LuaUnit.

### Running Tests

To run all tests with coverage report:

```bash
./RunTests.bat
```

This will:
- Execute all unit and integration tests
- Generate a code coverage report using LuaCov
- Verify that coverage requirements are met

### Test Structure

Tests are organized by type and mirror the source code structure:

```
Tests/
├── Unit/                          # Isolated component tests
│   ├── Domain/                    # Domain value object tests
│   │   ├── ArmorTest.lua
│   │   ├── DamageTest.lua
│   │   ├── MeleeTest.lua
│   │   ├── MobLevelTest.lua
│   │   └── ResistanceTest.lua
│   └── Presentation/
│       └── Drawers/               # UI drawer tests
│           ├── ArmorDrawerTest.lua
│           ├── MeleeDrawerTest.lua
│           └── ResistancesDrawerTest.lua
├── Integration/                   # Cross-layer tests
│   └── Application/
│       └── ApplicationServiceTest.lua
├── Support/                       # Test utilities
│   ├── Mocks/
│   │   ├── MockEnvironment.lua
│   │   └── MockTooltipInterface.lua
│   └── CheckCoverage.lua
└── RunTests.lua                   # Test entry point
```

### Test Conventions

- Use exact assertions (assertEquals) rather than partial matches (assertStrContains) to ensure output format is exactly as expected
- All tests should verify wrap parameter and call count for tooltip interactions
- Test files should restore any modified global state in tearDown() methods