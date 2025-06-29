{pkgs ? import <nixpkgs> {}}:
with pkgs;
  mkShell {
    nativeBuildInputs = [
      nmap
      whois
      aircrack-ng
      wireshark-cli
      wireshark

      proxychains
      tor
      torsocks

      john
      medusa
      hashcat
      hashcat-utils

      metasploit
      burpsuite
      ghidra-bin

      theharvester
      sqlmap
    ];
  }
