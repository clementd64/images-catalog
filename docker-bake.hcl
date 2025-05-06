group "default" {
  targets = [
    "bird",
  ]
}

target "bird" {
  name = "bird-${replace(version, ".", "-")}"
  dockerfile = "./images/bird.Dockerfile"
  matrix = {
    version = ["v2.17.1", "v3.1.0"]
  }
  tags = [ "ghcr.io/clementd64/bird:${version}" ]
  contexts = {
    "fetch" = "https://gitlab.nic.cz/labs/bird/-/archive/${version}/bird-${version}.tar.gz"
  }
}
