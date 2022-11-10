vim.cmd [[

  augroup _jenkins
    autocmd!
    autocmd BufRead,BufNewFile Jenkinsfile setf groovy
  augroup END

  ]]
vim.api.nvim_create_augroup('bufcheck', {clear = true})
vim.cmd 'autocmd BufRead,BufNewFile *.yml set filetype=yaml.ansible'
-- reload config file on change
vim.api.nvim_create_autocmd('BufWritePost', {
    group    = 'bufcheck',
    pattern  = vim.env.MYVIMRC,
    command  = 'silent source %'})

    -- sync clipboards because I'm easily confused
    -- vim.api.nvim_create_autocmd('TextYankPost', {
    --     group    = 'bufcheck',
    --     pattern  = '*',
    --     callback = function() fn.setreg('+', fn.getreg('*'))
    --  end })

    -- start terminal in insert mode
--     vim.api.nvim_create_autocmd('TermOpen',     {
--         group    = 'bufcheck',
--         pattern  = '*',
--         command  = 'startinsert | set winfixheight'})
--
    -- start git messages in insert mode
    -- vim.api.nvim_create_autocmd('FileType',     {
    --     group    = 'bufcheck',
    --     pattern  = { 'gitcommit', 'gitrebase', },
    --     command  = 'startinsert | 1'})

   -- pager mappings for Manual
   -- vim.api.nvim_create_autocmd('FileType',     {
   --      group    = 'bufcheck',
   --      pattern  = 'man',
   --      callback = function()
   --        vim.keymap.set('n', '<enter>'    , 'K'    , {buffer=true})
   --        vim.keymap.set('n', '<backspace>', '<c-o>', {buffer=true})
   --        end })

-- vim.api.nvim_create_autocmd('BufRead', {
--     group    = 'bufcheck',
--     pattern  = '*.yml','*.yaml',
--     command  = function()
--       if search('hosts:|tasks:', 'nw') then
--         vim.bo.filetype = 'ansible'
--       end end })

    -- -- Return to last edit position when opening files
    -- vim.api.nvim_create_autocmd('BufReadPost',  {
    --     group    = 'bufcheck',
    --     pattern  = '*',
    --     callback = function()
    --       if fn.line("'\"") > 0 and fn.line("'\"") <= fn.line("$") then
    --          fn.setpos('.', fn.getpos("'\""))
    --          -- vim.cmd('normal zz') -- how do I center the buffer in a sane way??
    --          vim.cmd('silent! foldopen')
    --          end end })
