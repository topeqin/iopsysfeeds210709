rtpstart=$(uci -q get voice_client.SIP.rtpstart)
rtpstart=${rtpstart:-10000}
rtpend=$(uci -q get voice_client.SIP.rtpend)
rtpend=${rtpend:-20000}

iptables -I zone_wan_input -m udp -p udp --dport $rtpstart:$rtpend -m comment --comment "!fw3: Allow-RTP" -j ACCEPT
