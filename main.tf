terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "< 6.0.0"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "4.4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.32.0"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "2.15.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.3"
    }
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
    argocd = {
      source  = "argoproj-labs/argocd"
      version = "7.11.0"
    }
  }
  backend "s3" {
    bucket = "pkflores-general"
    key    = "terraform/pyroscope/main.tfstate"
    region = "us-east-1"
  }
}

provider "argocd" {
  server_addr = "argocd.pkflores.io:443"
  username    = data.vault_kv_secret_v2.argocd_creds.data["user"]
  password    = data.vault_kv_secret_v2.argocd_creds.data["password"]
}

provider "vault" {
  address         = "https://vault.pkflores.io"
  skip_tls_verify = false
}

data "vault_kv_secret_v2" "argocd_creds" {
  provider = vault
  mount    = "kvv2"
  name     = "argocd/server-creds"
}
