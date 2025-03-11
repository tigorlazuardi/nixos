{ pkgs, lib, ... }:
let
  lombokJar = builtins.fetchurl {
    url = "https://projectlombok.org/downloads/lombok-1.18.34.jar";
    sha256 = "sha256-wn1rKv9WJB0bB/y8xrGDcJ5rQyyA9zdO6x2CPobUuBo=";
  };
in
{
  programs.nixvim = {
    extraPlugins = [
      {
        plugin = pkgs.vimPlugins.nvim-jdtls;
        optional = true;
      }
    ];
    extraConfigLua = ''
      require("lz.n").load {
        "nvim-jdtls",
        ft = "java",
        after = function()
          local root_dir = require("lspconfig.configs.jdtls").root_dir
          local fname = vim.api.nvim_buf_get_name(0)
          local root = root_dir(fname)
          local project_name = vim.fs.basename(root)
          local cmd = {
            [[${lib.getExe pkgs.jdt-language-server}]],
            "-configuration",
            vim.fn.stdpath "cache" .. "/jdtls/" .. project_name .. "/config",
            "-data",
            vim.fn.stdpath "cache" .. "/jdtls/" .. project_name .. "/workspace",
            [[--jvm-arg=-javaagent:${lombokJar}]],
          }
          require("jdtls").start_or_attach {
            cmd = cmd,
            root_dir = root,
            init_options = {
              bundles = {
                vim.fn.glob(
                  [[${pkgs.vscode-extensions.vscjava.vscode-java-debug}/share/vscode/extensions/vscjava.vscode-java-debug/server/com.microsoft.java.debug.plugin-*.jar]],
                  1
                ),
              },
            },
          }
        end,
      }
    '';
  };
}
