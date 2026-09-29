variable "enable_default_standards" {
  default     = false
  description = "Whether AWS subscribes the account to its default standards automatically. Defaults to false so the standards you run are the ones listed in `standards` and nothing else — AWS's defaults change over time, and a control set that changes under you is not a baseline."
}

variable "control_finding_generator" {
  default     = "SECURITY_CONTROL"
  description = "How findings are generated (e.g. 'SECURITY_CONTROL' or 'STANDARD_CONTROL'). 'SECURITY_CONTROL' produces one finding per control regardless of how many standards include it, which is what you want unless you have a reason otherwise."

  validation {
    condition     = contains(["SECURITY_CONTROL", "STANDARD_CONTROL"], var.control_finding_generator)
    error_message = "control_finding_generator must be 'SECURITY_CONTROL' or 'STANDARD_CONTROL'."
  }
}

variable "auto_enable_controls" {
  default     = true
  description = "Whether new controls added to an enabled standard turn themselves on. True means the baseline keeps up with AWS; false means it only changes when you change it."
}

variable "standards" {
  default     = ["aws-foundational-security-best-practices/v/1.0.0"]
  description = "Standards to subscribe to, as ARN suffixes — the region and partition are filled in for you. Common values: 'aws-foundational-security-best-practices/v/1.0.0', 'cis-aws-foundations-benchmark/v/1.4.0', 'nist-800-53/v/5.0.0', 'pci-dss/v/3.2.1'. Each standard is billed per check, so add them deliberately."
}
