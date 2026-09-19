local M = {}

-- Default configuration options
M.config = {
	enabled = true, -- Enable the plugin automatically on startup
	width_percentage = 0.6, -- Width percentage for the focused window (60%)
	height_percentage = 0.6, -- Height percentage for the focused window (60%)
}

-- Internal tracking for the autocommand group and ID
local augroup = vim.api.nvim_create_augroup("SmartWindowFocus", { clear = true })
local autocmd_id = nil

-- Function to resize the currently focused window based on configured percentages
local function resize_windows()
	-- Get total layout dimensions of Neovim
	local total_width = vim.o.columns
	local total_height = vim.o.lines - 2 -- Subtract command line and statusline height

	-- Calculate target width and height using percentages
	local target_width = math.floor(total_width * M.config.width_percentage)
	local target_height = math.floor(total_height * M.config.height_percentage)

	-- Apply new dimensions to the current active window
	vim.api.nvim_win_set_width(0, target_width)
	vim.api.nvim_win_set_height(0, target_height)
end

-- Function to enable the smart focusing behavior
function M.enable()
	M.config.enabled = true
	if not autocmd_id then
		-- Create an autocommand triggered whenever entering a window
		autocmd_id = vim.api.nvim_create_autocmd("WinEnter", {
			group = augroup,
			callback = function()
				if M.config.enabled then
					resize_windows()
				end
			end,
		})
	end
	-- Instantly resize the current window upon enablement
	resize_windows()
	print("Smart Focus: ENABLED")
end

-- Function to disable the smart focusing and restore default Neovim layout
function M.disable()
	M.config.enabled = false
	if autocmd_id then
		-- Remove the autocommand listener
		vim.api.nvim_del_autocmd(autocmd_id)
		autocmd_id = nil
	end
	-- Reset all split sizes equally (default Neovim behavior)
	vim.cmd("wincmd =")
	print("Smart Focus: DISABLED (Normal Neovim)")
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

	-- Register user commands in Neovim
	vim.api.nvim_create_user_command("SmartWindowFocusEnable", M.enable, {})
	vim.api.nvim_create_user_command("SmartWindowFocusDisable", M.disable, {})
	vim.api.nvim_create_user_command("SmartWindowFocusToggle", M.toggle, {})

	-- Bind default keymap for fast toggling
	vim.keymap.set("n", "<leader>ft", M.toggle, { desc = "Toggle Smart Focus" })

	-- Trigger initial enablement if true
	if M.config.enabled then
		M.enable()
	end
end

return M
