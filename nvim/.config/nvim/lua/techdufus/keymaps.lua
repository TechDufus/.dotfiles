local opts = { noremap = true, silent = true }
local term_opts = { silent = true }

-- Shorten function name
local keymap = vim.api.nvim_set_keymap

--Remap space as leader key
keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Modes
--   normal_mode = "n",
--   insert_mode = "i",
--   visual_mode = "v",
--   visual_block_mode = "x",
--   term_mode = "t",
--   command_mode = "c",

-- Normal --
-- Better window navigation
keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("n", "<leader>w", ":Lex 30<cr>", opts)

-- System clipboard
-- Copy to clipboard in normal, visual, select and operator modes
keymap("n", "<leader>y", '"+y', opts)
keymap("v", "<leader>y", '"+y', opts)
keymap("x", "<leader>y", '"+y', opts)
keymap("n", "<leader>Y", '"+yy', opts)
keymap("v", "<leader>Y", '"+yy', opts)
keymap("x", "<leader>Y", '"+yy', opts)
  
-- Paste from clipboard in normal, visual, select and operator modes
keymap("n", "<leader>p", '"+p', opts)
keymap("v", "<leader>p", '"+p', opts)
keymap("x", "<leader>p", '"+p', opts)


-- Resize with arrows
keymap("n", "<C-Up>", ":resize -2<CR>", opts)
keymap("n", "<C-Down>", ":resize +2<CR>", opts)
keymap("n", "<C-Left>", ":vertical resize -2<CR>", opts)
keymap("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Navigate buffers
keymap("n", "<S-l>", ":bnext<CR>", opts)
keymap("n", "<S-h>", ":bprevious<CR>", opts)


-- Visual --
-- Stay in indent mode
keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)

-- Move text up and down
keymap("v", "<A-j>", ":m .+1<CR>==", opts)
keymap("v", "<A-k>", ":m .-2<CR>==", opts)
keymap("v", "p", '"_dP', opts)

-- Visual Block --
-- Move text up and down
keymap("x", "J", ":move '>+1<CR>gv-gv", opts)
keymap("x", "K", ":move '<-2<CR>gv-gv", opts)
keymap("x", "<A-j>", ":move '>+1<CR>gv-gv", opts)
keymap("x", "<A-k>", ":move '<-2<CR>gv-gv", opts)

-- Terminal --
-- Better terminal navigation
keymap("t", "<C-h>", "<C-\\><C-N><C-w>h", term_opts)
keymap("t", "<C-j>", "<C-\\><C-N><C-w>j", term_opts)
keymap("t", "<C-k>", "<C-\\><C-N><C-w>k", term_opts)
keymap("t", "<C-l>", "<C-\\><C-N><C-w>l", term_opts)

-- Telescope --
keymap("n", "<leader>pf", "<cmd>lua require'telescope.builtin'.find_files({ hidden = true })<cr>", opts)
keymap("n", "<leader>pg", "<cmd>lua require('telescope.builtin').live_grep({ hidden = true })<cr>", opts)
-- Telescope find files in nvim config directory
keymap("n", "<leader>rc", "<cmd>lua require'telescope.builtin'.find_files({cwd = '~/.dotfiles/nvim/.config/nvim'})<cr>", opts)

-- Harpoon --
keymap("n", "<leader>a", "<cmd>lua require'harpoon.mark'.add_file()<cr>", opts)
keymap("n", "<leader>e", "<cmd>lua require'harpoon.ui'.toggle_quick_menu()<cr>", opts)
keymap("n", "<leader>h", "<cmd>lua require'harpoon.ui'.nav_file(1)<cr>", opts)
keymap("n", "<leader>t", "<cmd>lua require'harpoon.ui'.nav_file(2)<cr>", opts)
keymap("n", "<leader>n", "<cmd>lua require'harpoon.ui'.nav_file(3)<cr>", opts)
keymap("n", "<leader>s", "<cmd>lua require'harpoon.ui'.nav_file(4)<cr>", opts)





