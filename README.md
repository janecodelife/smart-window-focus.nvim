# smart-window-focus.nvim

A lightweight, high-performance, and native Neovim plugin written in Lua that automatically resizes your active vertical split (`vsplit`) to a comfortable viewing


## 🚀 Features

- **Dynamic Resizing**: Automatically expands the active vertical split to a configured percentage (e.g., 65% width).
- **Perfect Equalization**: Smoothly distributes the remaining screen width equally among all other inactive splits (supports 2, 3, 4, or more splits without collapsing windows).
- **Smart Whitelisting**: Automatically ignores floating windows, terminal buffers, quickfix lists, and dashboard prompts.
- **Toggle on the fly**: Easily enable or disable the smart resizing behavior via a keymap or user command to return to standard vanilla Neovim split layouts.

## 📦 Installation



```lua
vim.pack.add({
	"https://github.com/janecodelife/smart-window-focus.nvim.git",
})

require("smart-window-focus").setup({
    width_percentage = 0.65, -- Resize focused window to take 65% of screen width
    enabled = true,          -- Enable the plugin automatically on startup
})

Add the following to your `init.lua` or `keymaps.lua` file:

-- Toggle smart window focus on and off using your preferred shortcut
vim.keymap.set("n", "<leader>ft", "<cmd>SmartWindowFocusToggle<cr>", { desc = "Toggle Smart Window Focus" })
```

## ⚙️ Configuration

You can customize the plugin by passing options into the `setup()` function:

| Option | Type | Default | Description |
| :--- | :--- | :--- | :--- |
| `width_percentage` | `float` | `0.65` | The width percentage assigned to your currently active split (from `0.1` to `1.0`). |
| `enabled` | `boolean` | `true` | Set to `false` if you don't want the plugin to start auto-resizing on launch. |

## 🎮 Keymaps & Commands

- `:SmartWindowFocusToggle` - Toggle the auto-resizing state.
- `:SmartWindowFocusEnable` - Turn on smart resizing behavior.
- `:SmartWindowFocusDisable` - Turn off smart resizing and revert to default balanced layout.

# Thank You
