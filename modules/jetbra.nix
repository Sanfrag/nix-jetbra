{
  config,
  pkgs,
  lib,
  ...
}:

with lib;

let
  cfg = config.programs.jetbra;

  trustCrtPath = ../jetbra/trust-crt;
  blockUrlKeywordsPath = ../jetbra/block_url_keywords;
  agentPath = ../jetbra/jetbra-agent.jar;
  vmoptionsPath = ../jetbra/vmoptions;
  templates = fileset.toList (fileset.fileFilter (file: file.type == "regular") vmoptionsPath);

  vmoptions = map (
    fileInfo:
    let
      originalContent = builtins.readFile fileInfo;
      baseName = builtins.baseNameOf fileInfo;
      newContent = originalContent + "\n-javaagent:${agentPath}";
    in
    {
      name = removeSuffix ".vmoptions" baseName;
      path = pkgs.writeText baseName newContent;
    }
  ) templates;

  vmoptionsScript = pkgs.writeScript "jetbrains.vmoptions.sh" (
    let
      exports = builtins.concatStringsSep "\n" (
        map (
          file:
          let
            nameUpper = toUpper file.name;
          in
          "export ${nameUpper}_VM_OPTIONS=\"${file.path}\""
        ) vmoptions
      );
    in
    "#!/bin/sh\nexport TRUST_CRT_DIR=\"${trustCrtPath}\"\nexport BLOCK_URL_KEYWORD_FILE_PATH=\"${blockUrlKeywordsPath}\"\n${exports}"
  );
in
{
  options.programs.jetbra = {
    enableBashIntegration = lib.hm.shell.mkBashIntegrationOption { inherit config; };
    enableZshIntegration = lib.hm.shell.mkZshIntegrationOption { inherit config; };
  };

  config = mkIf cfg.enable {
    home.file.".config/plasma-workspace/env/jetbrains.vmoptions.sh" = {
      source = vmoptionsScript;
    };

    programs.bash.initExtra = mkIf cfg.enableBashIntegration (''
      ___MY_VMOPTIONS_SHELL_FILE="${vmoptionsScript}"; if [ -f "''${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "''${___MY_VMOPTIONS_SHELL_FILE}"; fi
    '');
    programs.zsh.initExtra = mkIf cfg.enableZshIntegration ''
      ___MY_VMOPTIONS_SHELL_FILE="${vmoptionsScript}"; if [ -f "''${___MY_VMOPTIONS_SHELL_FILE}" ]; then . "''${___MY_VMOPTIONS_SHELL_FILE}"; fi
    '';
  };
}
