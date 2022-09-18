local M = {}

local api = vim.api
local fn = vim.fn

local lunajson = require("lunajson")

Tasks = {}

-- _read_config reads the config file and returns a table
local function _read_config()
	local file = io.open("./launch.json", "r")
	if not file then
		return nil
	end

	local content = file:read("*all")
	file:close()
	return lunajson.decode(content)
end

-- _create_temp_window creates a temporary window and buffer to start a job with termopen
local function _create_temp_window()
	local buf = api.nvim_create_buf(false, false)

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

-- _ui_select_task opens a vim ui select window to select a task
local function _ui_select_task()
	local task = nil

	local all_task_keys = {}
	for k, _ in pairs(Tasks) do
		table.insert(all_task_keys, k)
	end

	vim.ui.select(all_task_keys, {
		prompt = "select task",
		options = {},
	}, function(choice)
		task = Tasks[choice]
	end)

	return task
end

-- Task meta class
Task = { command = nil, cwd = nil, mode = "default" }

-- Task:new is the constructor for Task
function Task:new(o)
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	self._job = nil
	self._buf = nil
	return o
end

-- Task:run runs the task and puts it into the background
function Task:start()
	local buf, win = _create_temp_window()
	self._buf = buf

	local job = fn.termopen(self.command, {
		cwd = self.cwd,
	})

	self._job = job

	api.nvim_win_close(win, true)
end

function Task:stop()
	if self._job then
		api.nvim_buf_delete(self._buf, { force = true })
		api.nvim_jobstop(self._job)
	end
end

function Task:restart()
	self:stop()
	self:start()
end

function Task:open()
	if self.mode == "vsplit" then
		api.nvim_command("vsplit")
	else
		api.nvim_command("botright 10split")
	end

	print(self)
	api.nvim_set_current_buf(self._buf)
end

function M.start_all()
	for _, task in ipairs(_read_config()) do
		local t = Task:new(task)
		t:start()
		Tasks[task.command] = t

		for k, v in pairs(t) do
			print(k, v)
		end
	end
end

function M.open_task(opts)
	local task = _ui_select_task()

	task:open()
end

function M.restart_task(opts)
	local task = _ui_select_task()

	task:restart()
end

return M
