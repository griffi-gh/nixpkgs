{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  installShellFiles,
  versionCheckHook,
  nix-update-script,

  buildClient ? true,
  buildServer ? false,
}:

rustPlatform.buildRustPackage (finalAttrs: {
  pname =
    if buildClient && buildServer then
      "lore-full"
    else if buildServer then
      "lore-server"
    else
      "lore-client";
  version = "0.8.4";

  src = fetchFromGitHub {
    owner = "EpicGames";
    repo = "lore";
    tag = "v${finalAttrs.version}";
    hash = "sha256-RxeRjSfi0Waz7Sm4Ifu4eBhfnez/qAvgs+bP1BTYAS0=";
  };

  cargoHash = "sha256-kPow7EzpNXTUgkZW0guXgVcTxE645uPc0U9EEsrsFM8=";

  cargoBuildFlags =
    lib.optionalAttrs buildServer [
      "--package=lore-server"
    ]
    ++ lib.optionalAttrs buildClient [
      "--package=lore-client"
    ];
  cargoTestFlags = finalAttrs.cargoBuildFlags;

  checkFlags = [
    "--skip=quic::" # Failed to establish client connection
  ];

  env = {
    RUSTFLAGS = "--cfg tokio_unstable --cfg uuid_unstable -C force-unwind-tables=yes -C force-frame-pointers=yes";
    VERGEN_IDEMPOTENT = "true";
    LORE_BUILD_VERSION_NAME = finalAttrs.version;
  };

  nativeBuildInputs = [
    installShellFiles
  ];

  postInstall = lib.optionalString (stdenv.buildPlatform.canExecute stdenv.hostPlatform) ''
    ${lib.optionalString buildClient ''
      installShellCompletion --cmd lore \
        --bash <($out/bin/lore completions bash) \
        --fish <($out/bin/lore completions fish) \
        --zsh <($out/bin/lore completions zsh)
    ''}
    ${lib.optionalString buildServer ''
      installShellCompletion --cmd loreserver \
        --bash <($out/bin/loreserver completions bash) \
        --fish <($out/bin/loreserver completions fish) \
        --zsh <($out/bin/loreserver completions zsh)
    ''}
  '';

  doInstallCheck = true;
  nativeInstallCheckInputs = [
    versionCheckHook
  ];

  passthru.updateScript = nix-update-script { };

  meta = {
    description = "Next-generation open source version control system maintained by Epic Games";
    longDescription = ''
      Maintained by Epic Games, Lore is designed for unprecedented scalability of
      both data and teams. It’s optimized for projects—including games and
      entertainment—that combine code with large binary assets, and caters for the
      needs of developers and artists alike.
    '';
    homepage = "https://lore.org/";
    changelog = "https://github.com/EpicGames/lore/releases/tag/v${finalAttrs.version}";
    downloadPage = "https://github.com/EpicGames/lore/releases/";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ griffi-gh ];
  }
  // lib.optionalAttrs buildServer {
    mainProgram = "loreserver";
  }
  // lib.optionalAttrs buildClient {
    mainProgram = "lore";
  };
})
