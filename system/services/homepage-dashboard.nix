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
      package = pkgs.homepage-dashboard.overrideAttrs { enableLocalIcons = true; };
      enable = true;
      settings = {
        title = "Tigor's Homeserver";
        description = "A front face for my personal server";
        startUrl = "https://tigor.web.id";
        disableUpdateCheck = true;
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
          Media = {
            iconStyle = "theme";
            style = "row";
            columns = 2;
          };
          "Media Collector" = {
            iconStyle = "theme";
            style = "row";
            columns = 4;
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
                  icon = "forgejo.svg";
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
            "Media" =
              [ ]
              ++ (optional config.profile.services.navidrome.enable {
                Navidrome = {
                  description = "Self-hosted music server and streaming service";
                  href = "https://music.tigor.web.id";
                  icon = "navidrome.svg";
                };
              })
              ++ (optional config.profile.services.jellyfin.enable {
                Jellyfin = {
                  description = "Media server for movies, tv shows, and downloaded videos";
                  href = "https://jellyfin.tigor.web.id";
                  icon = "jellyfin.svg";
                };
              })
              ++ (optional config.profile.services.suwayomi.enable {
                Suwayomi = {
                  description = "Manga collection, reader, and downloader. NSFW Warning!";
                  href = "https://manga.tigor.web.id";
                  icon = "suwayomi.svg";
                };
              })
              ++ (optional config.profile.services.kavita.enable {
                Kavita = {
                  description = "Collection of books and web novels";
                  href = "https://kavita.tigor.web.id";
                  icon = "kavita.svg";
                };
              });
          }
          {
            "Media Collector" =
              [ ]
              ++ (optional config.profile.services.jellyfin.enable {
                Jellyseerr = {
                  description = "Front end for Radarr, Sonarr, and Links collection to Jellyfin";
                  href = "https://jellyseerr.tigor.web.id";
                  icon = "jellyseerr.svg";
                };
              })
              ++ (optional config.profile.podman.soulseek.enable {
                "Soulseek (Nicotine)" = {
                  description = "Peer-to-peer music sharing client";
                  href = "https://soulseek.tigor.web.id";
                  icon = "soulseek.png";
                };
              })
              ++ (optional config.profile.podman.servarr.radarr.enable {
                Radarr = {
                  description = "Movie torrent searcher and scraper";
                  href = "https://radarr.tigor.web.id";
                  icon = "radarr.svg";
                };
              })
              ++ (optional config.profile.podman.servarr.sonarr.enable {
                "Sonarr (Anime)" = {
                  description = "Anime torrent searcher and scraper";
                  href = "https://sonarr-anime.tigor.web.id";
                  icon = "sonarr.svg";
                };
              })
              ++ (optional config.profile.podman.servarr.sonarr.enable {
                Sonarr = {
                  description = "TV Shows torrent searcher and scraper";
                  href = "https://sonarr.tigor.web.id";
                  icon = "sonarr.svg";
                };
              })
              ++ (optional config.profile.podman.servarr.prowlarr.enable {
                Prowlarr = {
                  description = "Torrent Indexer for movies, tv shows, and other media types";
                  href = "https://prowlarr.tigor.web.id";
                  icon = "prowlarr.svg";
                  widget = {
                    type = "prowlarr";
                    url = "http://prowlarr.local";
                    key = "{{HOMEPAGE_VAR_PROWLARR_API_KEY}}";
                  };
                };
              })
              ++ (optional config.profile.podman.servarr.bazarr.enable {
                Bazarr = {
                  description = "Subtitle downloader for movies and tv shows";
                  href = "https://bazarr.tigor.web.id";
                  icon = "bazarr.svg";
                };
              })
              ++ (optional config.profile.podman.ytptube.enable {
                Ytptube = {
                  description = "Frontend for yt-dlp. Download videos from Youtube and other sites. NSFW Warning!";
                  href = "https://ytptube.tigor.web.id";
                  icon = "youtube-dl.svg";
                };
              });
          }
          {
            Services =
              [ ]
              ++ (optional config.profile.services.adguardhome.enable {
                "Adguard Home" = {
                  description = "Network filter, router-wide ad blocker, and recursive DNS Server to reduce outbound traffic";
                  href = "https://adguard.tigor.web.id";
                  icon = "adguard-home.svg";
                  widget = {
                    type = "adguard";
                    url = "https://adguard.tigor.web.id";
                    username = "{{HOMEPAGE_VAR_ADGUARD_USERNAME}}";
                    password = "{{HOMEPAGE_VAR_ADGUARD_PASSWORD}}";
                  };
                };
              })
              ++ (optional config.profile.podman.qbittorrent.enable {
                QBittorrent = {
                  description = "Torrent client";
                  href = "https://qbittorrent.tigor.web.id";
                  icon = "qbittorrent.svg";
                  widget = {
                    type = "qbittorrent";
                    url = "http://10.88.0.7:8080";
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
                  icon = "syncthing.svg";
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
                  icon = "grafana.svg";
                };
              })
              ++ (optional config.profile.services.ntfy-sh.enable {
                Ntfy-sh = {
                  description = "Notification services across devices";
                  href = "https://ntfy.tigor.web.id";
                  icon = "ntfy.svg";
                };
              });
          }
        ];
      widgets = [
        {
          greeting = {
            text_size = "2xl";
            text = "Tigor's Homeserver";
          };
        }
        {
          search = {
            provider = "google";
            focus = true;
            showSearchSuggestions = true;
            target = "_blank";
          };
        }
        {
          resources = {
            cpu = true;
            memory = true;
            cputemp = true;
            uptime = true;
            units = "metric";
            network = true;
            disk = [
              "/"
              "/nas"
              "/wolf"
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
        proxyPass = "http://unix:${config.services.anubis.instances.homepage-dashboard.settings.BIND}";
        proxyWebsockets = true;
      };
    };

    services.anubis.instances.homepage-dashboard.settings.TARGET =
      "http://0.0.0.0:${toString config.services.homepage-dashboard.listenPort}";
  };
}
