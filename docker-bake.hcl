group "default" {
  targets = [
    "patroni",
  ]
}

target "patroni" {
  name = "patroni-${replace(version, ".", "-")}"
  dockerfile = "images/patroni.Dockerfile"
  matrix = {
    version = [ "18" ]
  }
  tags = [ "ghcr.io/clementd64/pkg/patroni:${version}" ]
  contexts = {
    "postgres:alpine" = "docker-image://postgres:${version}-alpine"
  }
}

target "bird" {
  name = "bird-${replace(version, ".", "-")}"
  dockerfile = "./images/bird.Dockerfile"
  matrix = {
    version = ["v2.17.1", "v3.1.0"]
  }
  tags = [ "ghcr.io/clementd64/pkg/bird:${version}" ]
  contexts = {
    "fetch" = "https://gitlab.nic.cz/labs/bird/-/archive/${version}/bird-${version}.tar.gz"
  }
}

target "fex" {
  name = "fex"
  dockerfile = "./images/fex.Dockerfile"
  matrix = {
    version = ["2511"]
  }
  tags = [ "ghcr.io/clementd64/pkg/fex:${version}" ]
  contexts = {
    fetch = "https://github.com/FEX-Emu/FEX.git#FEX-${version}"
  }
  platforms = [ "linux/arm64" ]
}

target "krakend" {
  name = "krakend"
  dockerfile = "./images/krakend.Dockerfile"
  matrix = {
    version = ["2.10.0"]
  }
  tags = [ "ghcr.io/clementd64/pkg/krakend:v${version}" ]
  args = {
    VERSION = version
  }
  contexts = {
    fetch = "https://github.com/krakend/krakend-ce.git#v${version}"
    schema = "https://raw.githubusercontent.com/krakend/krakend-schema/refs/heads/main/v${join(".", slice(split(".", version), 0, 2))}/krakend.json"
  }
}
