variable "resource_group_location" {
  default     = "westeurope"
  description = "Location of the resource group."
}

variable "name" {
  type        = string
  default     = "demo"
  description = "Name prefix of the Demo resources"
}