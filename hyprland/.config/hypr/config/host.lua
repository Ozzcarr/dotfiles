-- Gaming bits (Steam, OBS, the Wooting's macro keys) only exist on the desktop.

local file = io.open("/etc/hostname")
local name = file:read("l")
file:close()

return {
  name = name,
  desktop = name ~= "laptop",
}
