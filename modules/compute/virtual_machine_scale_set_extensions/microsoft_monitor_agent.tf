resource "azurerm_virtual_machine_scale_set_extension" "vmss_ext_mma" {
  for_each                     = var.extension_name == "microsoft_monitoring_agent" ? toset(["enabled"]) : toset([])
  virtual_machine_scale_set_id = var.virtual_machine_scale_set_id
  
  auto_upgrade_minor_version   = try(var.extension.auto_upgrade_minor_version, null)  
  automatic_upgrade_enabled    = try(var.extension.automatic_upgrade_enabled, null)  
  force_update_tag             = try(var.extension.force_update_tag, null)  
  name                         = var.virtual_machine_scale_set_os_type == "linux" ?  "OMSExtension" : "MMAExtension"
  publisher                    = "Microsoft.EnterpriseCloud.Monitoring"
  type                         = var.virtual_machine_scale_set_os_type == "linux" ?  "OmsAgentForLinux" : "MicrosoftMonitoringAgent"
  type_handler_version         = try(var.extension.type_handler_version, var.virtual_machine_scale_set_os_type == "linux" ?  "1.4" : "1.0")
  
  protected_settings = jsonencode({
    "workspaceKey" = "${try(
                        var.log_analytics_workspaces[var.extension.workspace.lz_key][var.extension.workspace.key].primary_shared_key,
                        var.log_analytics_workspaces[var.client_config.landingzone_key][var.extension.workspace.key].primary_shared_key,
                        var.extension.workspace.primary_shared_key
                      )}"
  })

  settings = jsonencode({
    "workspaceId" = "${try(
                        var.log_analytics_workspaces[var.extension.workspace.lz_key][var.extension.workspace.key].workspace_id,
                        var.log_analytics_workspaces[var.client_config.landingzone_key][var.extension.workspace.key].workspace_id,
                        var.extension.workspace.id
                      )}"
    "stopOnMultipleConnections" = try(var.extension.stopOnMultipleConnections, true)  
  })
}
