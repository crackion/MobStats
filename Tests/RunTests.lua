-- RunTests.lua
-- Entry point for running all tests with LuaUnit and LuaCov

-- Start LuaCov for code coverage
require('luacov')

-- Load LuaUnit
local lu = require('luaunit')

-- Load unit tests - Utils
require('Tests.Unit.UtilsTest')

-- Load unit tests - Domain
require('Tests.Unit.Domain.ArmorTest')
require('Tests.Unit.Domain.DamageTest')
require('Tests.Unit.Domain.MeleeTest')
require('Tests.Unit.Domain.MobLevelTest')
require('Tests.Unit.Domain.ResistanceTest')

-- Load unit tests - Presentation
require('Tests.Unit.Presentation.UtilsTest')
require('Tests.Unit.Presentation.Drawers.ArmorDrawerTest')
require('Tests.Unit.Presentation.Drawers.MeleeDrawerTest')
require('Tests.Unit.Presentation.Drawers.ResistancesDrawerTest')

-- Load integration tests
require('Tests.Integration.Application.ApplicationServiceTest')

-- Run all tests
os.exit(lu.LuaUnit.run())
