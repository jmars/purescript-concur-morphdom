{ name = "concur-morphdom"
, version = "0.1.0"
, respository = "https://github.com/jmars/purescript-concur-morphdom"
, dependencies =
  [ "console", "effect", "psci-support", "concur-core", "web-html" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
