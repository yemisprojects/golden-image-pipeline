###############################################################################
# BACKEND FOR TF RESOURCES CREATED WITHIN PIPELINE
################################################################################
module "pipeline_backend" {
  source = "../modules/setup-backend"

  table_name  = "ami-pipeline-tfstate-db-lock"
  bucket_name = "ami-pipeline-tfstate-s3-${random_integer.gami.id}"
}

resource "random_integer" "gami" {
  min = 1000000000
  max = 9999999999
}

