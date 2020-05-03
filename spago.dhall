{ name = "concur-morphdom"
, version = "v0.3.0"
, repo = "https://github.com/jmars/purescript-concur-morphdom"
, dependencies =
  [ "console", "effect", "psci-support", "concur-core", "web-html" ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
