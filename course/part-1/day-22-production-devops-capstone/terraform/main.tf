terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "architecture_note" {
  filename = "${path.module}/architecture.txt"
  content  = "FOMA capstone: infrastructure is managed separately from application deployment."
}
