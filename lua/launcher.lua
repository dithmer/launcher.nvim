local M = {}

local api = vim.api
local fn = vim.fn

local lunajson = require("lunajson")

function read_config()
	local file = io.open("./launch.json", "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()
	return lunajson.decode(content)
end

local function create_temp_window(b)
	local buf = b

	if not buf then
		buf = api.nvim_create_buf(false, false)
	end

	local win = api.nvim_open_win(buf, true, {
		relative = "editor",
		width = 1,
		height = 1,
		row = 0,
		col = 0,
		style = "minimal",
	})
	return buf, win
end

local function start_job(cmd, cwd, b)
	local buf, win = create_temp_window(b)
	local job = fn.termopen(cmd, {
		stdout_buffered = false,
		detached = false,
		cwd = cwd,
		on_exit = function(_, code, _)
			print("Job exited with code " .. code)
		end,
	})
	api.nvim_win_close(win, true)
	Jobs[cmd] = {
		buf = buf,
		job = job,
		cwd = cwd,
	}
	return buf, job
end

Jobs = {}

function M.start_all()
	for _, launch in ipairs(read_config()) do
		print("executing", launch["command"])
		local buf, job = start_job(launch["command"], launch["cwd"], nil)
	end
end

local function select_job_from_list()
	local job = nil

	local all_jobs_keys = {}
	for k, _ in pairs(Jobs) do
		table.insert(all_jobs_keys, k)
	end

	local cmd = nil

	vim.ui.select(all_jobs_keys, {
		prompt = "Select job",
		options = {},
	}, function(choice)
		job = Jobs[choice]
		cmd = choice
	end)

	return cmd, job
end

function M.open_window(opts)
	local _, job = select_job_from_list()

	local buf = job.buf

	-- open buffer in split
	api.nvim_command("botright 10split")
	api.nvim_set_current_buf(buf)
end

function M.list_jobs()
	local i = 0
	for key, job in pairs(Jobs) do
		print(i, key, job.buf)
		i = i + 1
	end
end

function M.restart_job(opts)
	local cmd, job = select_job_from_list()

	fn.jobstop(job.job)

	local b, j = start_job(cmd, job.cwd, nil)
end

return M
