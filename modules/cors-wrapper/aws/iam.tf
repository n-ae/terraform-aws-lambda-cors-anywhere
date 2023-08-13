data "aws_iam_policy" "aws_lambda_basic_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

data "aws_iam_policy_document" "sts_assume_role" {
  statement {
    actions = [
      "sts:AssumeRole",
    ]
    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "role" {
  assume_role_policy = data.aws_iam_policy_document.sts_assume_role.json
  managed_policy_arns = [
    data.aws_iam_policy.aws_lambda_basic_execution.arn,
  ]
}
