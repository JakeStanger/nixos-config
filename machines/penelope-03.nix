{ ... }: {
  # iptables modules needed by deluge vpn container
  boot.kernelModules = [
    "iptable_filter"
    "iptable_nat"
    "iptable_mangle"
    "ip6table_filter"
    "ip6table_nat"
    "ip6table_mangle"
  ];
}
