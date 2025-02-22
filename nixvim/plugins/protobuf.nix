{ pkgs, ... }:
{
  programs.nixvim = {
    plugins.lsp.servers.buf_ls.enable = true;
    plugins.conform-nvim.settings.formatters_by_ft.protobuf = [
      "buf"
    ];
    extraPackages = with pkgs; [
      protobuf_27
      buf
      protoc-gen-go
      protoc-gen-connect-go
      protoc-gen-doc
      protoc-gen-es
      protoc-gen-connect-es
      protoc-gen-validate
    ];
  };
}
