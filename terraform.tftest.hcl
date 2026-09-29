mock_provider "aws" {
  mock_data "aws_region" {
    defaults = { region = "us-east-1" }
  }

  mock_data "aws_partition" {
    defaults = { partition = "aws" }
  }
}

run "an_unknown_finding_generator_is_rejected" {
  command = plan

  variables {
    control_finding_generator = "PER_STANDARD"
  }

  expect_failures = [var.control_finding_generator]
}

run "defaults_subscribe_only_to_the_foundational_standard" {
  command = apply

  assert {
    condition     = aws_securityhub_account.resource.enable_default_standards == false
    error_message = "AWS default standards should be off - a baseline that changes when AWS changes its mind is not a baseline."
  }

  assert {
    condition     = aws_securityhub_account.resource.control_finding_generator == "SECURITY_CONTROL"
    error_message = "Findings should be generated per security control, not per standard, so one misconfiguration is one finding."
  }

  assert {
    condition     = aws_securityhub_account.resource.auto_enable_controls
    error_message = "New controls in an enabled standard should turn themselves on by default."
  }

  assert {
    condition     = length(aws_securityhub_standards_subscription.resource) == 1
    error_message = "Exactly one standard should be subscribed by default."
  }

  assert {
    condition     = aws_securityhub_standards_subscription.resource["aws-foundational-security-best-practices/v/1.0.0"].standards_arn == "arn:aws:securityhub:us-east-1::standards/aws-foundational-security-best-practices/v/1.0.0"
    error_message = "The standards ARN should be assembled from the current partition and region."
  }
}

run "several_standards_can_be_subscribed" {
  command = plan

  variables {
    standards = [
      "aws-foundational-security-best-practices/v/1.0.0",
      "cis-aws-foundations-benchmark/v/1.4.0",
      "nist-800-53/v/5.0.0",
    ]
  }

  assert {
    condition     = length(aws_securityhub_standards_subscription.resource) == 3
    error_message = "Every listed standard should produce a subscription."
  }
}

run "standards_can_be_left_empty" {
  command = plan

  variables {
    standards = []
  }

  assert {
    condition     = length(aws_securityhub_standards_subscription.resource) == 0
    error_message = "An empty standards list should enable Security Hub without subscribing to anything."
  }
}
