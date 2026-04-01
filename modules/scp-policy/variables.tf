variable "name" {
  description = "Policy name"
  type        = string
}

variable "description" {
  description = "Policy description"
  type        = string
  default     = ""
}

variable "policy_content" {
  description = "JSON policy document"
  type        = string
}

variable "target_ids" {
  description = "OU or account IDs to attach the policy to"
  type        = list(string)
}

variable "tags" {
  description = "Tags to apply to the policy"
  type        = map(string)
  default     = {}
}
