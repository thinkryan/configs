local lsp = require("lspconfig")
local setup_buffer = require("lsp-setup/buffer_setup")
local oslib = require("lib/oslib")

-- setup keymaps and autocommands
local on_attach = function(client, buffer_nr)
    -- NOTE(vir): now using nvim-notify
    -- print("[LSP] Active")
    require("notify")(string.format('[LSP] %s\n[CWD] %s', client.name, oslib.get_cwd()), 'info',
                      {title = '[LSP] Active', timeout = 250})

    setup_buffer.setup_general_keymaps(client, buffer_nr)
    setup_buffer.setup_independent_keymaps(client, buffer_nr)
    setup_buffer.setup_options(client, buffer_nr)
    setup_buffer.setup_autocmds(client, buffer_nr)
    setup_buffer.setup_highlights()
end

local capabilities = require('cmp_nvim_lsp').update_capabilities(vim.lsp .protocol .make_client_capabilities())
capabilities.offsetEncoding = {'utf-16'}

-- pyright setup
lsp["pyright"].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

-- clangd setup
lsp["clangd"].setup {
    capabilities = capabilities,
    cmd = { "clangd", "--background-index", "--clang-tidy", "--completion-style=bundled", "--header-insertion=iwyu" },
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

-- sumneko_lua setup
local sumneko_lua_root = oslib.get_homedir() .. "/.local/lsp/lua-language-server/"
local sumneko_lua_bin = sumneko_lua_root .. "bin/" .. oslib.get_os() .. "/lua-language-server"
lsp["sumneko_lua"].setup {
    capabilities = capabilities,
    cmd = {sumneko_lua_bin, "-E", sumneko_lua_root .. "main.lua"},
    settings = {
        Lua = {
            runtime = {version = "LuaJIT", path = vim.split(package.path, ";")},
            diagnostics = {globals = {"vim", "use"}},
            workspace = {
                library = {
                    [vim.fn.expand("$VIMRUNTIME/lua")] = true,
                    [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true
                }
            }
        }
    },
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

-- cmake setup
lsp['cmake'].setup {
    capabilities = capabilities,
    on_attach = on_attach,
    flags = {debounce_text_changes = 150}
}

-- null-ls setup
local formatting = require('null-ls').builtins.formatting
local diagnostics = require('null-ls').builtins.diagnostics
require('null-ls').setup({
    sources = { formatting.lua_format, formatting.autopep8, formatting.prettier, diagnostics.flake8 },
    capabilities = capabilities,
    on_attach = function(client, buffer_nr)
        require("notify")(string.format('[LSP] %s\n[CWD] %s', client.name, oslib.get_cwd()), 'info',
                          {title = '[LSP] Active', timeout = 250})
        setup_buffer.setup_independent_keymaps(client, buffer_nr)
    end
})
