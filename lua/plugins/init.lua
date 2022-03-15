if not exists(INSTALL_PATH) then
  notify { message = "packer.nvim doesn't exist. Cloning..." }
  PACKER_BOOTSTRAP = system {
    "git",
    "clone",
    "--depth",
    "1",
    "https://github.com/wbthomason/packer.nvim",
    INSTALL_PATH,
  }

  if not pcall(cmd, "packadd packer.nvim") then
    notify "Check your internet connection."
  end
end

if not exists(COMPILE_PATH) then
  notify "Couldn't find plugin specifications. Syncing now..."
  PACKER_BOOTSTRAP = true
  _ = pcall(cmd, "packadd packer.nvim")
end

local packer = require "packer"
packer.init(require "configs.core.packer")
packer.reset()

for _, module in
  ipairs {
    "plugins.health",
    "plugins.cmp",
    "plugins.core",
    "plugins.utils",
    "plugins.lsp",
    "plugins.treesitter",
    "plugins.others",
    "plugins.dev",
    "plugins.editing",
    "plugins.workflow",
    "plugins.telescope",
    "plugins.ui",
  }
do
  utils.load_module(packer, require(module))
end

if PACKER_BOOTSTRAP then
  packer.sync()
  packer.on_compile_done = schedule_wrap(function()
    _ = pcall(require, "configs.core.impatient")
    notify {
      message = "Run :LspInstall and :TSStart or, press\n<leader>l and <leader>T",
      icon = " ",
      title = "KrakenVim",
    }
  end)
end

return setmetatable({}, {
  __index = function(_, operation)
    return packer[operation]
  end,
})

-- vim:ft=lua
