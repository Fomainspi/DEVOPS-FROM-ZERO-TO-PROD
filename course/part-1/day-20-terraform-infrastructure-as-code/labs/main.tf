terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

resource "local_file" "foma_demo" {
  filename = "${path.module}/foma-output.txt"
  content  = "FOMA Terraform lab — infrastructure as code"
}

output "file_path" {
  value = local_file.foma_demo.filename
}
