local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

require("lazy").setup {{
  "folke/tokyonight.nvim",
  lazy = false,
  priority = 1000,
 }, {
   "neovim/nvim-lspconfig"
 }, {
    "Exafunction/codeium.nvim",
    dependencies = {
        "nvim-lua/plenary.nvim",
        "hrsh7th/nvim-cmp",
    },
    config = function()
        require("codeium").setup({
        })
    end
 }, {
     'hrsh7th/cmp-nvim-lsp'
 }, {
     'nvim-telescope/telescope.nvim', tag = '0.1.5',
     dependencies = { 'nvim-lua/plenary.nvim' }
  }, {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate"
  }, {
    'windwp/nvim-autopairs',
    event = "InsertEnter",
    opts = {} -- this is equalent to setup({}) function
  }
}

vim.cmd[[colorscheme tokyonight]]

-- Setup language servers.
local lspconfig = require('lspconfig')
lspconfig.pyright.setup {}
lspconfig.clangd.setup {}
lspconfig.zls.setup {}
lspconfig.rust_analyzer.setup {
  -- Server-specific settings. See `:help lspconfig-setup`
  settings = {
    ['rust-analyzer'] = {},
  },
}


-- Global mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist)

-- Use LspAttach autocommand to only map the following keys
-- after the language server attaches to the current buffer
vim.api.nvim_create_autocmd('LspAttach', {
  group = vim.api.nvim_create_augroup('UserLspConfig', {}),
  callback = function(ev)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'

    -- Buffer local mappings.
    -- See `:help vim.lsp.*` for documentation on any of the below functions
    local opts = { buffer = ev.buf }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end,
})

local cmp = require 'cmp'
cmp.setup {
  mapping = cmp.mapping.preset.insert({
    ["<C-p>"] = cmp.mapping.select_prev_item(), -- previous suggestion
    ["<C-n>"] = cmp.mapping.select_next_item(), -- next suggestion
    ["<C-b>"] = cmp.mapping.scroll_docs(-4),
    ["<C-f>"] = cmp.mapping.scroll_docs(4),
    ["<C-Space>"] = cmp.mapping.complete(), -- show completion suggestions
    ["<C-e>"] = cmp.mapping.abort(), -- close completion window
    ["<CR>"] = cmp.mapping.confirm({ select = false }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'codeium' },
  }
}

vim.cmd[[
set tabstop=4     "tab width
set shiftwidth=4  "indent size
set expandtab     "use space to instead the tab character
set smarttab
]]

local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, {})
vim.keymap.set('n', '<leader>fg', builtin.live_grep, {})
vim.keymap.set('n', '<leader>fb', builtin.buffers, {})
vim.keymap.set('n', '<leader>fh', builtin.help_tags, {})

local random = math.random
math.randomseed(os.time())
function gen_unique_identifier()
    local template ='yxxxxxxx_xxxx_xxxx_xxxx_xxxxxxxxxxxx'
    return string.gsub(template, '[xy]', function (c)
        local v = (c == 'x') and random(0, 0xf) or random(0xa, 0xf)
        return string.format('%X', v)
    end)
end

vim.api.nvim_create_autocmd({"BufNewFile"}, {
  pattern = {'*.h'},
  callback = function(ev)
    local guard = gen_unique_identifier()
    vim.api.nvim_buf_set_lines(0, 0, 5, false, {
      '#ifndef ' .. guard,
      '#define ' .. guard,
      '',
      string.format('#endif /* %s */', guard)
    })
    vim.api.nvim_win_set_cursor(0, {3, 0})
    vim.cmd 'startinsert'
  end
})

local enabled_component = {"terminal"}

for _, component in ipairs(enabled_component) do
    require(component)()
end
