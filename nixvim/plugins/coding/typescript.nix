{ unstable, ... }:
{
  programs.nixvim = {
    plugins = {
      none-ls.sources.formatting.prettierd = {
        enable = true;
        package = unstable.prettierd;
        disableTsServerFormatter = true;
      };
      lsp.servers.vtsls = {
        enable = true;
        package = unstable.vtsls;
        settings = {
          complete_function_calls = true;
          vtsls = {
            enableMoveToFileCodeAction = true;
            autoUseWorkspaceTsdk = true;
            experimental = {
              maxInlayHintLength = 30;
              completion = {
                enableServerSideFuzzyMatch = true;
              };
            };
          };
          typescript = {
            updateImportsOnFileMove.enabled = "always";
            suggest.completeFunctionCalls = true;
            inlayHints = {
              enumMemberValues.enabled = true;
              functionLikeReturnTypes.enabled = true;
              parameterNames.enabled = "literals";
              parameterTypes.enabled = true;
              propertyDeclarationTypes.enabled = true;
              variableTypes.enabled = false;
            };
          };
        };
      };
    };
  };
}
