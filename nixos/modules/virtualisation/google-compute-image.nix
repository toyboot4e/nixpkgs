{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
let
  cfg = config.virtualisation.googleComputeImage;
  defaultConfigFile = pkgs.writeText "configuration.nix" ''
    { ... }:
    {
      imports = [
        <nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>
      ];
    }
  '';
  virtualisationOptions = import ./virtualisation-options.nix;
in
{

  imports = [
    ./google-compute-config.nix
    virtualisationOptions.diskSize
    (lib.mkRenamedOptionModuleWith {
      sinceRelease = 2411;
      from = [
        "virtualisation"
        "googleComputeImage"
        "diskSize"
      ];
      to = [
        "virtualisation"
        "diskSize"
      ];
    })
  ];

  options = {
    virtualisation.googleComputeImage.configFile = mkOption {
      type = with types; nullOr str;
      default = null;
      description = ''
        A path to a configuration file which will be placed at `/etc/nixos/configuration.nix`
        and be used when switching to a new configuration.
        If set to `null`, a default configuration is used, where the only import is
        `<nixpkgs/nixos/modules/virtualisation/google-compute-image.nix>`.
      '';
    };

    virtualisation.googleComputeImage.compressionLevel = mkOption {
      type = types.int;
      default = 6;
      description = ''
        GZIP compression level of the resulting disk image (1-9).
      '';
    };
    virtualisation.googleComputeImage.efi = mkEnableOption "EFI booting";
  };

  #### implementation
  config = {
    boot.initrd.availableKernelModules = [ "nvme" ];
    boot.loader.grub = mkIf cfg.efi {
      device = mkForce "nodev";
      efiSupport = true;
      efiInstallAsRemovable = true;
    };

    fileSystems."/boot" = mkIf cfg.efi {
      device = "/dev/disk/by-label/ESP";
      fsType = "vfat";
    };

    system.build.googleComputeImage = import ../../lib/make-disk-image.nix {
      name = "google-compute-image";
      postVM = ''
        PATH=$PATH:${
          with pkgs;
          lib.makeBinPath [
            gnutar
            gzip
          ]
        }
        pushd $out
        mv $diskImage disk.raw
        tar -Sc disk.raw | gzip -${toString cfg.compressionLevel} > \
          nixos-image-${config.system.nixos.label}-${pkgs.stdenv.hostPlatform.system}.raw.tar.gz
        rm $out/disk.raw
        popd
      '';
      format = "raw";
      configFile = if cfg.configFile == null then defaultConfigFile else cfg.configFile;
      partitionTableType = if cfg.efi then "efi" else "legacy";
      inherit (config.virtualisation) diskSize;
      inherit config lib pkgs;
    };

  };

}
