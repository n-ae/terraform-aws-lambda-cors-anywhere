locals {
  dist_path = "dist"
  path = {
    dist         = local.dist_path
    git          = "${local.dist_path}/tmp.git"
    package_file = "${local.dist_path}/bootstrap.zip"
  }
}

resource "terraform_data" "dist" {
  input = {
    path                  = local.path
    cors_anywhere_version = var.cors_anywhere_version
  }

  triggers_replace = {
    version          = var.cors_anywhere_version
    source_code_hash = fileexists(local.path.package_file) ? filebase64sha256(local.path.package_file) : null
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = <<-EOT
mktemp -d --tmpdir=${self.input.path.git}
git -c advice.detachedHead=false \
  --work-tree=${self.input.path.dist} clone --depth=1 \
  --branch ${self.input.cors_anywhere_version} \
  git@github.com:Rob--W/cors-anywhere.git \
  ${self.input.path.git}
rm -rf ${self.input.path.git}
EOT
    interpreter = [
      "sh",
      "-c",
    ]
  }

  provisioner "local-exec" {
    working_dir = path.module
    command     = <<-EOT
pushd ${self.input.path.dist}
cp ../aws_lambda_wrapper/index.js .
. ../aws_lambda_wrapper/build.sh
popd
EOT
    interpreter = [
      "sh",
      "-c",
    ]
  }

  provisioner "local-exec" {
    when        = destroy
    working_dir = path.module
    command     = <<-EOT
rm -rf ${self.input.path.dist}
EOT
    interpreter = [
      "sh",
      "-c",
    ]
  }
}

module "aws" {
  source        = "./modules/aws"
  function_name = var.function_name
  allow_origins = var.allow_origins

  depends_on = [
    terraform_data.dist,
  ]
}
