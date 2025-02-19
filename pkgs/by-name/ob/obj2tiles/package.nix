{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  pkgs,
}:
buildDotnetModule rec {
  pname = "obj2tiles";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "OpenDroneMap";
    repo = "Obj2Tiles";
    rev = "refs/tags/v${version}";
    hash = "sha256-GLMLBmkVhuh8iYAxjD2XXnOvkw8dMuKTH49vvvSNHBI=";
  };

  projectFile = "Obj2Tiles.sln";
  nugetDeps = ./deps.json;

  dotnet-sdk = pkgs.dotnetCorePackages.sdk_8_0_3xx;
  dotnet-runtime = pkgs.dotnetCorePackages.runtime_8_0;

  executables = [ meta.mainProgram ];

  meta = {
    description = "Converts OBJ files to OGC 3D tiles by performing splitting, decimation and conversion";
    homepage = "https://github.com/OpenDroneMap/Obj2Tiles";
    changelog = "https://github.com/OpenDroneMap/Obj2Tiles/releases/tag/v1.0.13";
    license = lib.licenses.agpl3Only;
    mainProgram = "Obj2Tiles";
    maintainers = with lib.maintainers; [
      griffi-gh
      mapperfr
    ];
  };
}
