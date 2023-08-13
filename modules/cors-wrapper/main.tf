locals {
  module_abs_path = abspath(path.module)
  path = {
    dist         = "${local.module_abs_path}/dist"
    package_file = abspath("${local.module_abs_path}/bootstrap.zip")
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
    working_dir = local.module_abs_path
    command     = <<-EOT
git clone --depth 1 --branch ${self.input.cors_anywhere_version} git@github.com:Rob--W/cors-anywhere.git ${self.input.path.dist} &2>/dev/null
EOT
    interpreter = [
      "sh",
      "-c",
    ]
  }

  provisioner "local-exec" {
    working_dir = self.input.path.dist
    command     = <<-EOT
cp ${local.module_abs_path}/aws_lambda_wrapper/index.js .
. ${local.module_abs_path}/aws_lambda_wrapper/build.sh
EOT
    interpreter = [
      "sh",
      "-c",
    ]
  }

  provisioner "local-exec" {
    when    = destroy
    command = <<-EOT
rm -rf ${self.input.path.dist}
EOT
    interpreter = [
      "sh",
      "-c",
    ]
  }
}

module "aws" {
  source        = "./aws"
  function_name = var.function_name
  allow_origins = var.allow_origins

  depends_on = [
    terraform_data.dist,
  ]
}
