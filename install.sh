#!/bin/sh

readonly SERVICE_NAME="rrm_nr"

log() {
  local text="${1:?Missing: Text}"

  logger -t "$SERVICE_NAME" -p daemon.info "$text"
  echo "$text"
}

install_prerequisite_pkg() {
  local pkg_name="${1:?Missing: Package name}"
  [ $(apk info | grep -c "$pkg_name") -ge 1 ] && return 0

  apk update
  apk add "$pkg_name" && log "Done installing: $pkg_name"
}

enable_and_start_service() {
  local service_name="${1:?Missing: Service name}"
  local command="service $service_name"

  $command enabled || $command enable
  $command running && $command restart || $command start
  log "Done enabling and starting service: $service_name"
}

install_service() {

  service $SERVICE_NAME stop &> /dev/null

  local tmp_file="$(mktemp)"
  local backup_config_file="/etc/sysupgrade.conf"

  local source_url="https://github.com/qosmio/openwrt-rrm-nr-distributor/raw/main"
  local item=
  for item in rrm_nr.bin rrm_nr.init; do
    curl -sJL "$source_url/$item" -o"$tmp_file"

    local dest_file="$(head -1 "$tmp_file" | cut -d' ' -f3)"
    tail -n +2 "$tmp_file" > "$dest_file"
    chmod +x "$dest_file"
    log "Done downloading to: $dest_file"

    [ $(grep -c "$dest_file" "$backup_config_file") -le 0 ] && {
      echo "$dest_file" >> "$backup_config_file"
      log "Added to backup list: $dest_file"
    }

    echo "" > "$tmp_file"
  done

  install_prerequisite_pkg "umdns"
  enable_and_start_service "umdns"
  enable_and_start_service "$SERVICE_NAME"

  log "Installation completed successfully."
}

install_service

