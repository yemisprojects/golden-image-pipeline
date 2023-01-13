################################################################################
# S3 BACKEND FOR MAIN INFRASTRUCTURE
################################################################################
module "main_backend" {
  source = "../modules/setup-backend"

  table_name  = "maininfra-tfstate-lock"
  bucket_name = "maininfra-tfstate-${random_integer.this.id}"
}

resource "random_integer" "this" {
  min   = 100000000000
  max   = 999999999999
}

