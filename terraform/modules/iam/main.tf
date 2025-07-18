// IAM roles and policies
resource "aws_iam_role" "myrole" {
  name               = "${var.name_prefix}-role"
  assume_role_policy = var.assume_role_policy

  tags = {
    name = "${var.name_prefix}-role"
  }
}

resource "aws_iam_policy" "mypolicy" {
  name        = "${var.name_prefix}-policy"
  path        = "/" //default is "/"
  description = var.policy_description
  policy      = var.policy_json
}

resource "aws_iam_role_policy_attachment" "mypolicy_attach" {
  role       = aws_iam_role.myrole.name
  policy_arn = aws_iam_policy.mypolicy.arn
}