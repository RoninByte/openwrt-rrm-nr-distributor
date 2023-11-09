#!/bin/sh

function install_prerequisite_pkg() {
    local pkg_name="${1:?Missing: Package name}"
    [ $( opkg list-installed | grep -c "$pkg_name" ) -ge 1 ] && return 0

    opkg update
    opkg install "$pkg_name"
}

function enable_and_start_service() {
    local service_name="${1:Missing: Service name}"

    service "$service_name" enable
    service "$service_name" start
}

function install_service() {
    local service_name="update_rrm_nr"

    service $service_name stop &> /dev/null

    local -r tmp_file="$( mktemp )"
    local -r backup_config_file="/etc/sysupgrade.conf"

    local -r source_url="https://github.com/pdsakurai/openwrt-rrm-nr-distributor/raw/main"
    local item=
    for item in bin initscript; do
        wget "$source_url/$item" -qO "$tmp_file"
        
        local dest_file="$( head -1 "$tmp_file" | cut -d' ' -f3 )"
        tail -n +2 "$tmp_file" > "$dest_file"
        chmod +x "$dest_file"

        [ $( grep -c "$dest_file" "$backup_config_file" ) -le 0 ] && echo "$dest_file" >> "$backup_config_file"

        echo "" > "$tmp_file"
    done

    install_prerequisite_pkg "umdns" && enable_and_start_service "umdns"
    enable_and_start_service "$service_name"

    local log="Installation completed successfully."
    logger -t "$service_name" -p daemon.info "$log"
    echo "$log"
};

install_service