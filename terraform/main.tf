
resource "azurerm_resource_group" "build_agent" {
  name     = "rg-build-agent"
  location = var.location
}

resource "azurerm_log_analytics_workspace" "example" {
  name                = "law-build-agent"
  location            = azurerm_resource_group.build_agent.location
  resource_group_name = azurerm_resource_group.build_agent.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
}

resource "azurerm_container_app_environment" "build_agent" {
  name                       = "cae-build-agent"
  location                   = azurerm_resource_group.build_agent.location
  resource_group_name        = azurerm_resource_group.build_agent.name
  log_analytics_workspace_id = azurerm_log_analytics_workspace.example.id
}

# If using a User Assigned identity for the container app job
# resource "azurerm_user_assigned_identity" "build_agent" {
#   location            = azurerm_resource_group.build_agent.location
#   name                = "id-build-agent"
#   resource_group_name = azurerm_resource_group.build_agent.name
# }

resource "azurerm_container_app_job" "build_agent" {
  name                         = "build-agent"
  container_app_environment_id = azurerm_container_app_environment.build_agent.id
  resource_group_name          = azurerm_resource_group.build_agent.name
  replica_timeout_in_seconds = 1800
  replica_retry_limit        = 0
  event_trigger_config {
    parallelism = 1
    replica_completion_count = 1
    scale {
        max_executions = 10
        min_executions = 0
        polling_interval_in_seconds = 30
        rules {
            name = "azure-pipelines"
            custom_rule_type = "azure-pipelines"
            metadata = {
                poolName = var.agent_pool
                targetPipelinesQueueLength = 1
            }
            authentication {
                trigger_parameter = "personalAccessToken"
                secret_name       = "personal-access-token"
            }
            authentication {
                trigger_parameter = "organizationURL"
                secret_name       = "organization-url"
            }
        }
    }
  }

 identity{
    type = "SystemAssigned"
 }

# If you want to use a User Assigned identity instead, for example, to allow assigning roles to a fixed identity
#   identity {
#     type         = "UserAssigned"
#     identity_ids = [azurerm_user_assigned_identity.build_agent.principal_id]
#   }

  secret {
    name  = "personal-access-token"
    value = var.personal_access_token
  }
  secret {
    name  = "organization-url"
    value = var.organization_url
  }

  template {
    container {
      name   = "examplecontainerapp"
      image  = "ghcr.io/dionmm/azdo-build-agent:latest"
      cpu    = 2
      memory = "4Gi"
    }
  }
}