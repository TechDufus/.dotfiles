vim.cmd [[

  augroup _jenkins
    autocmd!
    autocmd BufRead,BufNewFile Jenkinsfile setf groovy
  augroup END

  ]]
