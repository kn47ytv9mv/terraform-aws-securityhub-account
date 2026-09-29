# terraform-aws-securityhub-account

Terraform module enabling Security Hub in an account and subscribing it to
the standards it should be measured against.

## Cost

Security Hub is billed per security check performed and per finding
ingested, so cost tracks the number of standards enabled and the number of
resources in the account. Adding a standard adds its whole control set to
the per-check bill, which is why only the AWS Foundational Security Best
Practices standard is subscribed by default rather than every standard
available. See AWS's
[Security Hub pricing](https://aws.amazon.com/security-hub/pricing/) page
for current rates.

## Design

There is one Security Hub per account per region.

`enable_default_standards` is false so that the standards in force are the
ones listed in `standards` and nothing else. AWS revises its defaults over
time, and a control set that changes without a change on your side is not a
baseline.

`control_finding_generator` is `SECURITY_CONTROL`, which produces one
finding per control regardless of how many subscribed standards include
that control. The alternative produces one finding per standard per
control, so a single misconfiguration appears several times.

### Tagging

The `aws_securityhub_account` and `aws_securityhub_standards_subscription`
resources accept no tags, so this module takes no `tags` variable. A
consumer wanting account-wide tagging should set `default_tags` on the
provider, which this module honours wherever the resources support it.

### Standards are named by suffix

The `standards` variable takes ARN suffixes rather than full ARNs, because
the partition and region are properties of where the module is applied
rather than of the standard. The module assembles the ARN, so the same
configuration is portable across regions.

## Usage

```hcl
module "security_hub" {
  source = "kn47ytv9mv/securityhub-account/aws"
}
```

Or directly from this repository:

```hcl
module "security_hub" {
  source = "github.com/kn47ytv9mv/terraform-aws-securityhub-account"
}
```

With several standards in force:

```hcl
module "security_hub" {
  source = "kn47ytv9mv/securityhub-account/aws"

  standards = [
    "aws-foundational-security-best-practices/v/1.0.0",
    "cis-aws-foundations-benchmark/v/1.4.0",
    "nist-800-53/v/5.0.0",
  ]
}
```

## Requirements

| Name | Version |
|---|---|
| terraform | >= 1.2 |
| aws | ~> 6.61 |

## Providers

| Name | Version |
|---|---|
| aws | ~> 6.61 |

## Inputs

| Name | Description | Default | Required |
|---|---|---|---|
| enable_default_standards | Whether AWS subscribes the account to its default standards automatically. | `false` | no |
| control_finding_generator | How findings are generated (e.g. `'SECURITY_CONTROL'` or `'STANDARD_CONTROL'`). | `"SECURITY_CONTROL"` | no |
| auto_enable_controls | Whether new controls added to an enabled standard turn themselves on. | `true` | no |
| standards | Standards to subscribe to, as ARN suffixes. | `["aws-foundational-security-best-practices/v/1.0.0"]` | no |

## Outputs

| Name | Description |
|---|---|
| id | The account ID Security Hub is enabled in. |
| arn | The ARN of the Security Hub hub resource. |
| standards_arns | The ARNs of the standards subscribed to. |

## License

MIT — see [LICENSE.md](LICENSE.md).
