-- check_coverage.lua
-- Checks if code coverage is 100% by reading luacov report

local report = io.open("luacov.report.out", "r")
if not report then
    print("Error: luacov.report.out not found")
    os.exit(1)
end

for line in report:lines() do
    if line:match("^Total") then
        local coverage = line:match("(%d+%.%d+)%%")
        if coverage then
            print(line)
            if tonumber(coverage) < 100 then
                report:close()
                os.exit(1)
            end
            report:close()
            os.exit(0)
        end
    end
end

report:close()
print("Error: Could not find coverage summary")
os.exit(1)
