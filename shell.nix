{ pkgs, hostInfo, ... }: {
  users.users.jake.shell = pkgs.fish;

  environment.systemPackages = with pkgs; [
    git
    wget
    jq
    python3
    pkgs.zellij
    pkgs.corn-cli
  ];

  programs = {
    fish.enable = true;
    fish.interactiveShellInit =
      builtins.readFile ./configs/interactiveShellInit.fish;

    starship.enable = true;
    zoxide.enable = true;

    nh = {
      enable = true;
      clean.enable = true;
      flake = "github:jakestanger/nixos-config#${hostInfo.name}";
    };

    neovim = {
      enable = true;
      defaultEditor = true;
      viAlias = true;
      vimAlias = true;
      configure.customRC = builtins.readFile ./configs/vimrc;
    };
  };
}
