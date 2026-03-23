# -----------------------------------------------
# variables.tf — Input Variables
# -----------------------------------------------

variable "key_name" {
  description = "EC2 Key Pair name for SSH access (leave empty if not needed)"
  type        = string
  default     = ""
}
