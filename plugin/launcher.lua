local api = vim.api

local launcher = require("launcher")

api.nvim_create_user_command("LauncherStart", launcher.start_all, {})
api.nvim_create_user_command("LauncherOpen", launcher.open_task, {})
api.nvim_create_user_command("LauncherRestart", launcher.restart_task, {})

if vim.g.launcher_autostart then
	print("Launcher is autostarting")
	launcher.start_all()
end

api.nvim_set_keymap("n", "<leader>to", ":LauncherOpen<CR>", { noremap = true })
api.nvim_set_keymap("n", "<leader>tr", ":LauncherOpen<CR>", { noremap = true })
