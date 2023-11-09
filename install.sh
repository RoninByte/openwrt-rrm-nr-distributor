#!/bin/sh

readonly SERVICE_NAME="update_rrm_nr"

function log() {
    local text="${1:?Missing: Text}"

    logger -t "$SERVICE_NAME" -p daemon.info "$text"
    echo "$text"
}

function install_prerequisite_pkg() {
    local pkg_name="${1:?Missing: Package name}"
    [ $( opkg list-installed | grep -c "$pkg_name" ) -ge 1 ] && return 0

    opkg update
    opkg install "$pkg_name" && log "Done installing: $pkg_name"
}

function enable_and_start_service() {
    local service_name="${1:?Missing: Service name}"

    service "$service_name" enable
    service "$service_name" start
    log "Done enabling and starting service: $service_name"
}

function install_service() {

    service "$SERVICE_NAME" stop &> /dev/null

    local tmp_file="$( mktemp )"
    local backup_config_file="/etc/sysupgrade.conf"

    local source_url="https://github.com/pdsakurai/openwrt-rrm-nr-distributor/raw/main"
    local item=
    for item in bin initscript; do
        wget "$source_url/$item" -qO "$tmp_file"
        
        local dest_file="$( head -1 "$tmp_file" | cut -d' ' -f3 )"
        tail -n +2 "$tmp_file" > "$dest_file"
        chmod +x "$dest_file"
        log "Done downloading to: $dest_file"

        [ $( grep -c "$dest_file" "$backup_config_file" ) -le 0 ] && {
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