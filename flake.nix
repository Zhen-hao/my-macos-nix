{
  inputs = {
    # Principle inputs (updated by `nix run .#update`)
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nix-darwin.url = "github:lnl7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-flake.url = "github:srid/nixos-flake";
  };

  outputs = inputs@{ self, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "aarch64-darwin" ];
      imports = [ inputs.nixos-flake.flakeModule ];

      flake =
        let
          myUserName = "zhen";
          myHome = "/Users/${myUserName}";
        in
        {
          # Configurations for macOS machines
          # replace `Zhenhaos-MacBook-Pro-3` with your `hostname -s`; it is the same host name as in your nix-darwin configuration 
          darwinConfigurations."Zhenhaos-MacBook-Pro-3" = self.nixos-flake.lib.mkMacosSystem {

            nixpkgs.hostPlatform = "aarch64-darwin";
            nixpkgs.config.allowUnfree = true;
		
            services.nix-daemon.enable = true;
            
            users.users.${myUserName}.home = myHome;

            imports = [
              ({ pkgs, ... }: {
                security.pam.enableSudoTouchIdAuth = true;
                # Used for backwards compatibility, please read the changelog before changing.
                # $ darwin-rebuild changelog
                system.stateVersion = 4;
              })
              # Setup home-manager in nix-darwin config
              self.darwinModules_.home-manager
              {
                home-manager.users.${myUserName} = {
                  imports = [ self.homeModules.default ];
                  home.stateVersion = "24.05";
                  home.homeDirectory = myHome;
                };
              }
            ];
          };

          # home-manager configuration goes here.
          homeModules.default = { pkgs, ... }: {
            imports = [ ];
	    
            home.packages = with pkgs; [
              jdk17
              nodejs
            ];

            programs.git.enable = true;
            programs.starship.enable = true;
            
            programs.zsh = {
              enable = true;

              # As of 22-07-2024, the PATH config is still need; nixos-flake might make it work out of the box later.
              envExtra = ''
                export PATH=/etc/profiles/per-user/$USER/bin:/nix/var/nix/profiles/system/sw/bin:/usr/local/bin:$PATH
              '';
            };

            programs.vscode = {
              enable = true;
              # package = pkgs.vscodium;  #pkgs.vscode.fhs;
              userSettings = {
                "editor.cursorStyle" = "line";
                "editor.cursorWidth" = 4;
                "window.zoomLevel" = 1;
                "git.autofetch" = false;
                "diffEditor.ignoreTrimWhitespace" = true;
                "gitlens.views.lineHistory.enabled" = true;
                "gitlens.advanced.messages" = {
                  "suppressFileNotUnderSourceControlWarning" = true;
                };
                "files.exclude" = {
                  "**/.classpath" = true;
                  "**/.project" = true;
                  "**/.settings" = true;
                  "**/.factorypath" = true;
                };
                "files.watcherExclude" = {
                  "**/.bloop" = true;
                  "**/.metals" = true;
                  "**/.ammonite" = true;
                };
                # "remote.SSH.defaultExtensions" =
                #   [ "eamodio.gitlens" "scalameta.metals" "ms-python.python" ];
                "metals.javaHome" = "${myHome}/.nix-profile";
                "java.semanticHighlighting.enabled" = true;
                # "python.jediEnabled" = true;
                # "python.linting.pylintEnabled" = false;
                # "python.linting.enabled" = true;
                # "python.linting.flake8Enabled" = false;
              };
              extensions = with pkgs.vscode-extensions;
                [
                  bbenoist.nix
                  # ms-python.python
                  rust-lang.rust-analyzer
                  # scala-lang.scala
                  # scalameta.metals
                  # ms-vsliveshare.vsliveshare
                  ms-vscode-remote.remote-ssh
                ] ++ pkgs.vscode-utils.extensionsFromVscodeMarketplace [
                  # {
                  #   name = "Nix";
                  #   publisher = "bbenoist";
                  #   version = "1.0.1";
                  #   sha256 = "0zd0n9f5z1f0ckzfjr38xw2zzmcxg1gjrava7yahg5cvdcw6l35b";
                  # }
                  {
                    name = "metals";
                    publisher = "scalameta";
                    version = "1.37.0";
                    sha256 =
                      "QNXaqm5VnKJCLkLWfx3hC69cu0mRBpeuICup9jgpziw="; # 0000000000000000000000000000000000000000000000000000
                  }
                  {
                    name = "scala";
                    publisher = "scala-lang";
                    version = "0.5.7";
                    sha256 = "cjMrUgp2+zyqT7iTdtMeii81X0HSly//+gGPOh/Mfn4=";
                  }
                ];
            };

          };
        };
    };
}
