802.11k Neighbor Report distributor daemon
==========================================

## Features
- Multi-network support (different SSID for different networks)
- STA dependent band steering by advertising the other BSSes of the same AP
- Works out of the box after umdns is working
- Not too much but enough logs

## Prerequisite/s
- [Configured 802.11k](https://openwrt.org/docs/guide-user/network/wifi/basic?s[]=802&s[]=11k#neighbor_reports_options_80211k) on SSID/s across different routers and/or access points.

## To install/update
Run this command:  `wget -qO - https://kutt.it/update_rrm_nr | sh`

## Known issue/s
- With large number of APs (>20) the full umdns update takes a few interations/minutes