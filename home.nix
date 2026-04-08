{
  config,
  pkgs,
  lib,
  ...
}:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "huybin1234b";
  home.homeDirectory = "/home/huybin1234b";
  # Idc the doc : adding unfree software in too
  nixpkgs.config.allowUnfree = true;
  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.
  programs.git = {
    enable = true;
    settings = {
      user = {
        name = "huybin1234b";
        email = "officalhuybin1234b@duck.com";
      };
      safe = {
        directory = "*";
      };
    };
  };
  services.home-manager.autoUpgrade = {
    enable = true;
    useFlake = true;
    flakeDir = "/etc/nixos";
    frequency = "daily";
  };
  # Fish config come here
  programs.fish = {
    enable = true;
    plugins = [
      # example of fetch plugins straight from github
      #name = "z";
      #src = pkgs.fetchFromGitHub {
      #    owner = "jethrokuan";
      #    repo = "z";
      #    rev = "ddeb28a7b6a1f0ec6dae40c636e5ca4908ad160a";
      #    sha256 = "0c5i7sdrsp0q3vbziqzdyqn4fmp235ax4mn4zslrswvn8g3fvdyh";
      #  };
    ];
    functions = {
      nixos-rebuild-fmd = {
        body = ''
          read -l -P "Enter the commit message: " CommitMessage
          nixfmt /etc/nixos/configuration.nix
          nixfmt /etc/nixos/home.nix
          nixfmt /etc/nixos/flake.nix
          nixfmt /etc/nixos/hardware-configuration.nix
          set -l CurrentDirectory (pwd)
          cd /etc/nixos
          git commit -m "$CommitMessage" -a
          git push
          cd "$CurrentDirectory"
          sudo nixos-rebuild switch --flake /etc/nixos
        '';
      };
    };
  };
  # Enable eza
  programs.eza = {
    enable = true;
    enableFishIntegration = true;
    enableBashIntegration = true;
    git = true;
    colors = "always";
    icons = true;
    extraOptions = [
      "--group-directories-first"
      "--header"
      "--all"
      "--hyperlink"
      " --follow-symlinks"
      "--modified"
      "--octal-permissions"
      "--git-repos"
      "-@"
      "-Z"
    ];
  };
  # Enable zoxide
  programs.zoxide.enable = true;
  programs.zoxide.enableFishIntegration = true;
  programs.zoxide.enableBashIntegration = true;
  # Set up declaretive shell eyes candy thing
  home.activation.configure-tide = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ${pkgs.fish}/bin/fish -c "tide configure --auto --style=Lean --prompt_colors='True color' --show_time='24-hour format' --lean_prompt_height='Two lines' --prompt_connection=Disconnected --prompt_spacing=Sparse --icons='Many icons' --transient=No"
  '';
  # Setup github-cli
  programs.gh = {
    enable = true;

  };
  # Config for the terminal
  programs.ghostty = {
    enable = true;
    themes = {
      Toy-Chest = {
        palette = [
          "0=#2c3f58"
          "1=#be2d26"
          "2=#1a9172"
          "3=#db8e27"
          "4=#325d96"
          "5=#8a5edc"
          "6=#35a08f"
          "7=#23d183"
          "8=#336889"
          "9=#dd5944"
          "10=#31d07b"
          "11=#e7d84b"
          "12=#34a6da"
          "13=#ae6bdc"
          "14=#42c3ae"
          "15=#d5d5d5"
        ];
        background = "#24364b";
        foreground = "#31d07b";
        cursor-color = "#d5d5d5";
        cursor-text = "#141c25";
        selection-background = "#5f217a";
        selection-foreground = "#d5d5d5";

      };
    };
    enableBashIntegration = true;
    enableFishIntegration = true;
  };
  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = [
    # # Adds the 'hello' command to your environment. It prints a friendly
    # # "Hello, world!" when run.
    # pkgs.hello

    # # It is sometimes useful to fine-tune packages, for example, by applying
    # # overrides. You can do that directly here, just don't forget the
    # # parentheses. Maybe you want to install Nerd Fonts with a limited number of
    # # fonts?
    # (pkgs.nerdfonts.override { fonts = [ "FantasqueSansMono" ]; })

    # # You can also create simple shell scripts directly inside your
    # # configuration. For example, this adds a command 'my-hello' to your
    # # environment:
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
  ];

  # Home Manager is pretty good at managing dotfiles. The primary way to manage
  # plain files is through 'home.file'.
  home.file = {
    # # Building this configuration will create a copy of 'dotfiles/screenrc' in
    # # the Nix store. Activating the configuration will then make '~/.screenrc' a
    # # symlink to the Nix store copy.
    # ".screenrc".source = dotfiles/screenrc;

    # # You can also set the file content immediately.
    # ".gradle/gradle.properties".text = ''
    #   org.gradle.console=verbose
    #   org.gradle.daemon.idletimeout=3600000
    # '';
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/huybin1234b/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;
}
