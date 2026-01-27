{ ... }: {
  flake.modules.nixos.nixvim = { nixvim, pkgs, ... }: {
    imports = [
      nixvim.homeManagerModules.nixvim
    ];

    programs.nixvim = {
      enable = true;
      extraPlugins = with pkgs.vimPlugins; [
        vim-nix
      ];

      clipboard.providers.xclip.enable = true;

      plugins = {
        lualine.enable = true;
        telescope.enable = true;
        oil.enable = true;
        treesitter.enable = true;
        luasnip.enable = true;

        nvim-tree.enable = true;
        surround.enable = true;
        bufferline.enable = true;

        toggleterm.enable = true;

        cmp-buffer = {
          enable = true;
        };
        cmp-nvim-lsp = {
          enable = true;
        };
        cmp-path = {
          enable = true;
        };
        cmp_luasnip = {
          enable = true;
        };

        cmp = {
          enable = true;
          autoEnableSources = true;

          settings = {
            snippet.expand = ''
              function(args)
                require('luasnip').lsp_expand(args.body)
              end
            '';
            sources = [
              { name = "nvim_lsp"; }
              { name = "luasnip"; }
              {
                name = "buffer";
                option.get_bufnrs.__raw = "vim.api.nvim_list_bufs";
              }
              { name = "nvim_lua"; }
              { name = "path"; }
            ];

            mapping = {
              "<CR>" = "cmp.mapping.confirm({ select = true })";
              "<Tab>" = ''
                  cmp.mapping(
                    function(fallback)
                       if cmp.visible() then
                        cmp.select_next_item()
                       elseif luasnip and luasnip.expandable() then
                        luasnip.expand()
                       elseif luasnip and luasnip.expand_or_jumpable() then
                        luasnip.expand_or_jump()
                       elseif check_backspace and check_backspace() then
                        fallback()
                       else
                        fallback()
                       end
                    end
                  ,
                  { "i", "s" }
                )
              '';
            };
          };
        };
      };

      plugins.lsp = {
        enable = true;

        servers = {
          ruff.enable = true;
          hls.enable = true;
          ccls.enable = true;

          rust-analyzer.enable = true;
          rust-analyzer.installRustc = false;
          rust-analyzer.installCargo = false;

          ruby-lsp.enable = true;
          clojure-lsp.enable = true;
          zls.enable = true;

          html.enable = true;
          cssls.enable = true;

          nushell.enable = true;
          bashls.enable = true;

          nixd.enable = true;
          ltex.enable = true;
        };
      };

      plugins.alpha = {
        enable = true;
        theme = "dashboard";
      };

      opts = {
        number = true;
        relativenumber = true;
        expandtab = true;

        shiftwidth = 2;

      };

      keymaps = [
        {
          action = "<cmd>NvimTreeToggle<CR>";
          key = "<Space>-n";
          mode = "n";
        }

        {
          action = "<cmd>bnext<CR>";
          key = "<Tab>";
          mode = "n";
        }

        {
          action = "<cmd>bprevious<CR>";
          key = "<S-Tab>";
          mode = "n";
        }

        {
          action = "<cmd>Telescope find_files<CR>";
          key = "<Space>f";
          mode = "n";
        }

        {
          action = "<C-w>l";
          key = "<Space>l";
          mode = "n";
        }

        {
          action = "<C-w>h";
          key = "<Space>w";
          mode = "n";
        }

        {
          action = "<C-w>j";
          key = "<Space>j";
          mode = "n";
        }

        {
          action = "<C-w>k";
          key = "<Space>k";
          mode = "n";
        }

        {
          action = "<cmd>close<CR>";
          key = "<Space>x";
          mode = "n";
        }

        {
          action = "<cmd>ToggleTerm<CR>";
          key = "<Space>t";
          mode = "n";
        }
      ];

      globals.mapleader = " ";
    };
  };
}
