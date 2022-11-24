// Benchmarks and controls for specific services should override the "service" tag
locals {
  github_ho_common_tags = {
    category = "Compliance"
    plugin   = "github"
    service  = "GitHub"
  }
}

mod "github_ho" {
  # hub metadata
  title         = "Home Office Github Compliance Dashboard"
  description   = "Proof-of-concept for visualising and monitoring compliance control checks for best practice use of GitHub."
  color         = "#191717"
  documentation = file("./docs/index.md")
  icon          = ""
  categories    = ["best practices", "github"]

  opengraph {
    title        = ""
    description  = ""
    image        = ""
  }
}
