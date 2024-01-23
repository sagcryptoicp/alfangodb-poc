let upstream = https://github.com/dfinity/vessel-package-set/releases/download/mo-0.10.2-20231113/package-set.dhall sha256:6ce0f76863d2e6c8872a59bf5480b71281eb0e3af14c2bda7a1f34af556abab2
let Package =
    { name : Text, version : Text, repo : Text, dependencies : List Text }

let additions = [
  { 
    name = "base",
    version = "moc-0.9.8",
    repo = "https://github.com/dfinity/motoko-base",
    dependencies = [] : List Text
  },
  { 
    name = "base-0.7.3",
    version = "moc-0.7.3",
    repo = "https://github.com/dfinity/motoko-base",
    dependencies = [] : List Text 
  },
  {
    name = "array",
    version = "v0.2.1",
    repo = "https://github.com/aviate-labs/array.mo",
    dependencies = [ "base-0.7.3" ] : List Text
  },
  {
    name = "io",
    repo = "https://github.com/aviate-labs/io.mo",
    version = "v0.3.2",
    dependencies = [ "base-0.7.3" ]
  },
  {
    name = "encoding",
    version = "v0.4.1",
    repo = "https://github.com/aviate-labs/encoding.mo",
    dependencies = [ "base-0.7.3", "array" ]
  },
  {
    name = "rand",
    repo = "https://github.com/aviate-labs/rand.mo",
    version = "v0.2.3",
    dependencies = [] : List Text
  },
  {
    name = "ulid",
    version = "v0.1.3",
    repo = "https://github.com/aviate-labs/ulid.mo",
    dependencies = [] : List Text
  },
  { 
    name = "map",
    version = "v9.0.1",
    repo = "https://github.com/ZhenyaUsenko/motoko-hash-map",
    dependencies = [] : List Text
  },
] : List Package

in  upstream # additions
