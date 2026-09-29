data "aws_region" "current" {}

data "aws_partition" "current" {}

resource "aws_securityhub_account" "resource" {
  enable_default_standards  = var.enable_default_standards
  control_finding_generator = var.control_finding_generator
  auto_enable_controls      = var.auto_enable_controls
}

resource "aws_securityhub_standards_subscription" "resource" {
  for_each = toset(var.standards)

  standards_arn = format(
    "arn:%s:securityhub:%s::standards/%s",
    data.aws_partition.current.partition,
    data.aws_region.current.region,
    each.value,
  )

  depends_on = [aws_securityhub_account.resource]
}

output "id" {
  description = "The account ID Security Hub is enabled in. There is one Security Hub per account per region."
  value       = aws_securityhub_account.resource.id
}

output "arn" {
  description = "The ARN of the Security Hub hub resource."
  value       = aws_securityhub_account.resource.arn
}

output "standards_arns" {
  description = "The ARNs of the standards subscribed to."
  value       = [for subscription in aws_securityhub_standards_subscription.resource : subscription.standards_arn]
}
