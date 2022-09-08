
source /home/techdufus/.config/nvim/themes/airline.vim
source /home/techdufus/.config/nvim/general/sets.vim
source /home/techdufus/.config/nvim/plugins/plugins.vim


colorscheme gruvbox
highlight Normal guibg=none

let mapleader = " "
" nnoremap <leader>ps <cmd>lua require('telescope.builtin').grep_string({ search = vim.fn.input("Grep for > ")})
nnoremap <leader>ps <cmd>lua require('telescope.builtin').grep_string()<cr>


fun! TrimWhitespace()
    let l:save = winsaveview()
    keeppatterns %s/\s\+$//e
    call winrestview(l:save)
endfun

augroup TECHDUFUS
    autocmd!
    autocmd BufWritePre * :call TrimWhitespace()
augroup END



