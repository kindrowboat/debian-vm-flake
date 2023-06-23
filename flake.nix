{
  description = "A Debian Cloud Image running on QEMU";

  inputs.nixpkgs.url = github:NixOS/nixpkgs/master;

  outputs = { self, nixpkgs }:

  let
    system = "x86_64-linux";

    pkgs = nixpkgs.legacyPackages.${system};

    debianImage = pkgs.fetchurl {
      url = "https://cloud.debian.org/images/cloud/bookworm/20230612-1409/debian-12-nocloud-amd64-20230612-1409.qcow2";
      sha256 = "sha256-ecZj1dmyhhJ6SR73eh0rEy/Xk46EdD46t8/4oD/rZ5I=";
    };

  in
  {
    packages.${system} = {

      qemu-debian = pkgs.stdenv.mkDerivation {
        name = "qemu-debian";
        buildInputs = [ pkgs.qemu ];
        buildCommand = ''
          mkdir -p $out/bin
          echo "#!/bin/sh" > $out/bin/qemu-debian
          echo "if [ ! -f ./debian.qcow2 ]; then cp ${debianImage} ./debian.qcow2 && chmod 644 ./debian.qcow2; fi" >> $out/bin/qemu-debian
          echo "${pkgs.qemu}/bin/qemu-system-x86_64 -enable-kvm -m 4096 -hda ./debian.qcow2" >> $out/bin/qemu-debian
          chmod +x $out/bin/qemu-debian
        '';
      };
    };

    defaultPackage.${system} = self.packages.${system}.qemu-debian;
  };
}

