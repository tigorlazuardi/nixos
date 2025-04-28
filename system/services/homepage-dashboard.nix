{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.profile.services.homepage-dashboard;
in
{
  config = lib.mkIf cfg.enable {
    sops.secrets."homepage/env" = {
      sopsFile = ../../secrets/homepage.yaml;
    };
    services.homepage-dashboard = {
      enable = true;
      settings = {
        title = "Tigor's Homeserver";
        description = "A front face for my personal server";
        startUrl = "https://tigor.web.id";
        useEqualHeights = true;
        quicklaunch = {
          searchDescription = true;
          showSearchSuggestions = true;
        };
        layout = {
          "Git & Personal Projects" = {
            iconStyle = "theme";
            style = "row";
          };
          Services = {
            iconStyle = "theme";
            style = "row";
            columns = 4;
          };
          "Media Player" = {
            iconStyle = "theme";
            style = "row";
            columns = 2;
          };
          Monitoring = {
            iconStyle = "theme";
            style = "row";
            columns = 2;
          };
        };
      };
      services =
        let
          optional = lib.lists.optional;
        in
        [
          {
            "Git & Personal Projects" =
              [ ]
              ++ (optional config.profile.services.forgejo.enable {
                Forgejo = {
                  description = "Git repository for my personal projects";
                  href = "https://git.tigor.web.id";
                  icon = "si-forgejo";
                };
              })
              ++ (optional config.profile.podman.redmage.enable {
                Redmage = {
                  description = "Reddit Image Downloader. Powered using Go backend, templ rendering engine, and HTMX for reactivity. NSFW Warning!";
                  href = "https://redmage.tigor.web.id";
                  icon = "mdi-alpha-r-circle-outline";
                };
              });
          }
          {
            "Media Player" =
              [ ]
              ++ (optional config.profile.services.navidrome.enable {
                Navidrome = {
                  description = "Self-hosted music server and streaming service";
                  href = "https://music.tigor.web.id";
                  icon = "mdi-music-box";
                };
              })
              ++ (optional config.profile.services.jellyfin.enable {
                Jellyfin = {
                  description = "Media server for movies, tv shows, and downloaded videos";
                  href = "https://jellyfin.tigor.web.id";
                  icon = "si-jellyfin";
                };
              });
          }
          {
            "Media Collector" =
              [ ]
              ++ (optional config.profile.podman.servarr.prowlarr.enable {
                Prowlarr = {
                  description = "Torrent Indexer for movies, tv shows, and other media types";
                  href = "https://prowlarr.tigor.web.id";
                  icon =
                    let
                      logo = pkgs.fetchurl {
                        url = "https://prowlarr.com/logo/128.png";
                        hash = "sha256-prO4wlh3EN80S1Xuq0MU5CE6m8co3UI7NdbtAkwEwWk=";
                      };
                    in
                    "${logo}";
                };
              });
          }
          {
            Services =
              [ ]
              ++ (optional config.profile.services.adguardhome.enable {
                "Adguard Home" = {
                  description = "Network filter, ad blocker, and recursive DNS Server";
                  href = "https://adguard.tigor.web.id";
                  icon = "si-adguard";
                };
              })
              ++ (optional config.profile.podman.qbittorrent.enable {
                QBittorrent = rec {
                  description = "Torrent client";
                  href = "https://qbittorrent.tigor.web.id";
                  icon = "si-qbittorrent";
                  widget = {
                    type = "qbittorrent";
                    url = href;
                    username = "{{HOMEPAGE_VAR_QBITTORRENT_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_QBITTORRENT_PASSWORD}}";
                    enableLeechProgress = true;
                  };
                };

              })
              ++ (optional config.profile.services.syncthing.enable {
                Syncthing = {
                  description = "Data synchronization for multiple devices";
                  href = "https://syncthing.tigor.web.id";
                  icon = "si-syncthing";
                };
              })
              ++ (optional config.profile.podman.ytptube.enable {
                Ytptube = {
                  description = "Frontend for yt-dlp. Download videos from Youtube and other sites. NSFW Warning!";
                  href = "https://ytptube.tigor.web.id";
                  icon = "si-youtube";
                };
              })
              ++ (optional config.profile.podman.morphos.enable {
                Morphos = {
                  description = "Web file / image / video converter";
                  href = "https://morphos.tigor.web.id";
                  icon = "mdi-file-arrow-left-right-outline";
                };
              });
          }
          {
            Monitoring =
              [ ]
              ++ (optional config.profile.services.telemetry.grafana.enable {
                Grafana = {
                  description = "Homeserver in-depth monitoring dashboard";
                  href = "https://grafana.tigor.web.id";
                  icon = "si-grafana";
                };
              })
              ++ (optional config.profile.services.ntfy-sh.enable {
                Ntfy-sh = {
                  description = "Notification services across devices";
                  href = "https://ntfy.tigor.web.id";
                  icon = "si-ntfy";
                };
              });
          }
        ];
      widgets = [
        {
          resources = {
            label = "System";
            cpu = true;
            memory = true;
            cputemp = true;
            uptime = true;
            units = "metric";
            network = true;
            disk = [
              "/"
              "/nas"
            ];
          };
        }
      ];
      allowedHosts = "tigor.web.id";
      environmentFile = config.sops.secrets."homepage/env".path;
    };

    services.nginx.virtualHosts."tigor.web.id" = {
      forceSSL = true;
      useACMEHost = "tigor.web.id";
      locations."/" = {
        proxyPass = "http://0.0.0.0:${toString config.services.homepage-dashboard.listenPort}";
        proxyWebsockets = true;
      };
    };
  };
}
