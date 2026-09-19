local M = {}

-- Default configuration options (Strictly focused on width for vertical splits)
M.config = {
	enabled = true, -- Enable the plugin automatically on startup
	width_percentage = 0.65, -- Width percentage for the focused window (65%)
}

-- Internal tracking for the autocommand group and ID
local augroup = vim.api.nvim_create_augroup("SmartWindowFocus", { clear = true })
local autocmd_id = nil

-- Function to resize the currently focused window horizontally
local function resize_windows()
	-- 1. Ensure the current window is a normal layout window (not floating)
	local win_config = vim.api.nvim_win_get_config(0)
	if win_config.relative ~= "" then
		return
	end

	-- 2. Strictly target normal layout buffers (buftype must be empty for normal files)
	if vim.bo.buftype ~= "" then
		return
	end

	-- 3. Gather and count only regular file split windows in the current tabpage
	local windows = vim.api.nvim_tabpage_list_wins(0)
	local normal_splits_count = 0

	for _, win in ipairs(windows) do
		local cfg = vim.api.nvim_win_get_config(win)
		local buf = vim.api.nvim_win_get_buf(win)
		local buftype = vim.api.nvim_get_option_value("buftype", { buf = buf })

		-- Count window only if it is non-floating and hosts a standard text file
		if cfg.relative == "" and buftype == "" then
			normal_splits_count = normal_splits_count + 1
		end
	end

	-- If there is only one normal text file open, keep it full screen and exit
	if normal_splits_count <= 1 then
		return
	end

	-- 4. Equalize layouts horizontally first so remaining splits distribute evenly
	vim.cmd("wincmd =")

	-- Get total width dimensions of Neovim screen
	local total_width = vim.o.columns

	-- Calculate targeted width using user-defined scale percentage
	local target_width = math.floor(total_width * M.config.width_percentage)

	-- Safely apply width dimension to the active split window (height is untouched)
	pcall(vim.api.nvim_win_set_width, 0, target_width)
end

-- Function to enable the smart focusing behavior
function M.enable()
	M.config.enabled = true
	if not autocmd_id then
		-- Create autocommands triggered strictly when moving between windows or buffers
		autocmd_id = vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
			group = augroup,
			callback = function()
				if M.config.enabled then
					resize_windows()
				end
			end,
		})
	end
	-- Trigger instant width calculation check
	resize_windows()
	print("Smart Window Focus: ENABLED (V-Splits Only)")
end

-- Function to disable the smart focusing and restore default Neovim layout
function M.disable()
	M.config.enabled = false
	if autocmd_id then
		-- Clean up and unbind the autocommand hook
		vim.api.nvim_del_autocmd(autocmd_id)
		autocmd_id = nil
	end
	-- Re-balance all splits equally back to default vanilla Neovim state
	vim.cmd("wincmd =")
	print("Smart Window Focus: DISABLED (Normal Neovim)")
end

-- Function to toggle between enabled and disabled states
function M.toggle()
	if M.config.enabled then
		M.disable()
	else
		M.enable()
	end
end

-- Main setup function to initialize the plugin with user options
function M.setup(opts)
	-- Merge user options with default configurations
	M.config = vim.tbl_deep_extend("force", M.config, opts or {})

	-- Register runtime user commands inside Neovim core
	vim.api.nvim_create_user_command("SmartWindowFocusEnable", M.enable, {})
	vim.api.nvim_create_user_command("SmartWindowFocusDisable", M.disable, {})
	vim.api.nvim_create_user_command("SmartWindowFocusToggle", M.toggle, {})

	-- Map the toggle command to global shortcut sequence
	vim.keymap.set("n", "<leader>ft", M.toggle, { desc = "Toggle Smart Window Focus" })

	-- Run on startup if configured to true
	if M.config.enabled then
		M.enable()
	end
end

return M
