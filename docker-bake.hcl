group "default" {
  targets = [
    "bird",
  ]
}

target "bird" {
  dockerfile = "./images/bird.Dockerfile"
  tags = [ "ghcr.io/clementd64/bird:v3.1.0" ]
  contexts = {
    "fetch" = "https://gitlab.nic.cz/labs/bird/-/archive/v3.1.0/bird-v3.1.0.tar.gz"
  }
}
