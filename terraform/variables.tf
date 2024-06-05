variable "location" {
  type        = string
  description = "The Azure region resources will be created in"
  default     = "uksouth"
}

variable "organization_url" {
  type        = string
  description = "The Azure DevOps organisation URL"
  default     = "https://dev.azure.com/Contoso"
}

variable "personal_access_token" {
  type        = string
  description = "A PAT for Azure DevOps with 'Read & Manage' permissions on the required agent pool"
}

variable "agent_pool" {
  type        = string
  description = "Name of the agent pool in Azure DevOps"
}