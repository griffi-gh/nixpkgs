{
  lib,
  stdenv,
  fetchFromGitLab,
  sbt,
  coursier,
  jdk11,
  jre,
  stripJavaArchivesHook,
  makeWrapper,
}:
let
  sbt' = sbt.override {
    jre = jdk11;
  };
in
stdenv.mkDerivation (finalAttrs: {
  pname = "ocelot-desktop";
  version = "1.12.0";

  __darwinAllowLocalNetworking = true;

  src = fetchFromGitLab {
    group = "cc-ru";
    owner = "ocelot";
    repo = "ocelot-desktop";
    rev = "v${finalAttrs.version}";
    hash = "sha256-I920uL6/FawP+2N5Ak0pmNRLaxuy0NZqfkTI4hpqIGw=";
    fetchSubmodules = true;
  };

  patches = [
    ./use-coursier.patch
  ];

  deps = stdenv.mkDerivation {
    name = "${finalAttrs.pname}-deps-${finalAttrs.version}";
    buildCommand = ''
      cp ${finalAttrs.src}/* . -r
      mkdir -p $out
      ${coursier}/bin/cs fetch --cache $out
    '';
    outputHashMode = "recursive";
    outputHash = lib.fakeHash;
  };

  nativeBuildInputs = [
    sbt'
    jdk11
    stripJavaArchivesHook
    makeWrapper
  ];

  buildPhase = ''
    runHook preBuild

    cp --no-preserve=mode,ownership -r ${finalAttrs.deps} ./.deps
    export COURSIER_CACHE=$(pwd)/.deps
    sbt assembly --java-home ${jdk11.home}

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/{bin,share/${finalAttrs.pname}
    install -Dm644 target/scala-2.13/ocelot-desktop.jar $out/share/${finalAttrs.pname}/ocelot-desktop.jar

    makeWrapper ${jre}/bin/java $out/bin/ocelot-desktop \
      --set JAVA_HOME ${jre.home}
      --add-flags "-cp $out/share/${finalAttrs.pname}/ocelot-desktop.jar org.foo.Main"

    runHook postInstall
  '';

  meta = {
    description = "An advanced OpenComputers emulator";
    homepage = "https://ocelot.fomalhaut.me/desktop";
    changelog = "https://gitlab.com/cc-ru/ocelot/ocelot-desktop/-/releases/v${finalAttrs.version}";
    license = lib.licenses.mit;
    mainProgram = "ocelot-desktop";
    platforms = with lib.platforms; linux ++ darwin;
    maintainers = with lib.maintainers; [ griffi-gh ];
  };
})
