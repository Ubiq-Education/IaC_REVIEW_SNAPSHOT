terraform {
  required_version = "~>1.9"

  required_providers {
    bunnynet = {
      source  = "BunnyWay/bunnynet"
      version = ">=0.19.2, <0.21.0"
    }

    time = {
      source  = "hashicorp/time"
      version = "~>0.12"
    }
  }
}
