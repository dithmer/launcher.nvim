local api = vim.api

local launcher = require("launcher")

api.nvim_create_user_command("LauncherStart", launcher.start_all, {})
api.nvim_create_user_command("LauncherOpen", launcher.open_window, { nargs = "?" })
api.nvim_create_user_command("LauncherRestart", launcher.restart_job, { nargs = "?" })

if vim.g.launcher_autostart then
	print("Launcher is autostarting")
	launcher.start_all()
end
