{ unstable, pkgs, ... }:
{
  programs.nixvim = {
    plugins.lsp.servers.buf_ls = {
      enable = true;
      package = unstable.buf;
    };
    extraPackages = with pkgs; [
      protobuf_27
      protoc-gen-go
      protoc-gen-connect-go
      protoc-gen-doc
      protoc-gen-es
      protoc-gen-connect-es
      protoc-gen-validate
    ];
  };
}
