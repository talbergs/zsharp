{ bundlerApp }:
bundlerApp {
  pname = "sass";
  exes = [ "sass" ];
  gemdir = ./.;
}
