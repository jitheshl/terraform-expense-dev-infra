#!/bin/bash
admin_user = openvpn
admin_pw = openvpn@321
route_gw = 1
route_dns = 1
sudo /usr/local/openvpn_as/scripts/sacli --user openvpn --new_pass 'openvpn@321' SetLocalPassword
