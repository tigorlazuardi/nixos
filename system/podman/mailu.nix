{ config, lib, ... }:
let
  name = "mailu";
  inherit (lib) mkIf;
  ip = "10.88.1.1";
  image = {
    admin = "ghcr.io/mailu/admin:2024.06";
    imap = "ghcr.io/mailu/dovecot:2024.06";
    smtp = "ghcr.io/mailu/postfix:2024.06";
    webmail = "ghcr.io/mailu/webmail:2024.06";
  };
  settings = {
    # Main mail domain
    DOMAIN = "tigor.web.id";

    # Hostnames for this server, separated with commas
    HOSTNAMES = "mail.tigor.web.id";

    # Postmaster local part (will append the main mail domain)
    POSTMASTER = "admin";

    # Choose how secure connections will behave (value: letsencrypt, cert, notls, mail, mail-letsencrypt)
    #
    # This mailu is expected for internal use only, so we will not use TLS.
    TLS_FLAVOR = "notls";

    # Authentication rate limit per IP (per /24 on ipv4 and /48 on ipv6)
    AUTH_RATELIMIT_IP = "5/hour";

    # Authentication rate limit per user (regardless of the source-IP)
    AUTH_RATELIMIT_USER = "50/day";

    # Opt-out of statistics, replace with "True" to opt out
    DISABLE_STATISTICS = "True";

    # Expose the admin interface (value: true, false)
    ADMIN = "true";

    # Choose which webmail to run if any (values: roundcube, snappymail, none). To enable this feature, recreate the docker-compose.yml file via setup.
    WEBMAIL = "roundcube";

    # Expose the API interface (value: true, false)
    API = "false";

    # Dav server implementation (value: radicale, none). To enable this feature, recreate the docker-compose.yml file via setup.
    WEBDAV = "none";

    # Antivirus solution (value: clamav, none). To enable this feature, recreate the docker-compose.yml file via setup.
    ANTIVIRUS = "none";

    # Scan Macros solution (value: true, false). To enable this feature, recreate the docker-compose.yml file via setup.
    SCAN_MACROS = "false";

    ###################################
    # Mail settings
    ###################################

    # Message size limit in bytes
    # Default: accept messages up to 50MB
    # Max attachment size will be 33% smaller
    MESSAGE_SIZE_LIMIT = "50000000";

    # Message rate limit (per user)
    MESSAGE_RATELIMIT = "200/day";

    # Networks granted relay permissions
    # Use this with care, all hosts in this networks will be able to send mail without authentication!
    RELAYNETS = "";

    # Will relay all outgoing mails if configured
    RELAYHOST = "";

    # Enable fetchmail
    FETCHMAIL_ENABLED = "False";

    # Fetchmail delay
    FETCHMAIL_DELAY = "600";

    # Recipient delimiter, character used to delimiter localpart from custom address part
    RECIPIENT_DELIMITER = "+";

    # DMARC rua and ruf email
    DMARC_RUA = "admin";
    DMARC_RUF = "admin";

    # Welcome email, enable and set a topic and body if you wish to send welcome
    # emails to all users.
    WELCOME = "false";

    # Maildir Compression
    # choose compression-method, default: none (value: gz, bz2, zstd)
    COMPRESSION = "gz";
    # change compression-level, default: 6 (value: 1-9)
    COMPRESSION_LEVEL = "9";

    # IMAP full-text search is enabled by default.
    # Set the following variable to off in order to disable the feature
    # or a comma separated list of language codes to support
    FULL_TEXT_SEARCH = "en";

    ###################################
    # Web settings
    ###################################

    # Path to redirect / to
    WEBROOT_REDIRECT = "/webmail";

    # Path to the admin interface if enabled
    WEB_ADMIN = "/admin";

    # Path to the webmail if enabled
    WEB_WEBMAIL = "/webmail";

    # Path to the API interface if enabled
    WEB_API = "/api";

    # Website name
    SITENAME = "Mailu";

    # Linked Website URL
    WEBSITE = "https://mail.tigor.web.id";

    ###################################
    # Advanced settings
    ###################################
    # Number of rounds used by the password hashing scheme
    CREDENTIAL_ROUNDS = "12";
    # Timezone for the Mailu containers. See this link for all possible values https://en.wikipedia.org/wiki/List_of_tz_database_time_zones
    TZ = "Asia/Jakarta";
  };
in
{
  config = mkIf config.profile.podman.mailu.enable {
    sops.secrets."mailu/env".sopsFile = ../../secrets/mailu.yaml;
  };
}
