output "resource_group_name" {
  value = module.resource_group.name
}

output "hub_namespace_id" {
  description = "Id of Event Hub Namespace."
  value       = module.eventhub.namespace_id
}

output "hub_ids" {
  description = "Map of hubs and their ids."
  value       = module.eventhub.hub_ids
}

output "hub_keys" {
  description = "Map of hubs with keys => primary_key / secondary_key mapping."
  sensitive   = true
  value       = module.eventhub.keys
}

output "hub_authorization_keys" {
  description = "Map of authorization keys with their ids."
  value       = module.eventhub.authorization_keys
}

output "hub_private_dns_zone_ids" {
  description = "Map of Private dns zones and their ids."
  value       = module.eventhub.private_dns_zone_ids
}

output "hub_private_endpoint_ids" {
  description = "Map of Private endpoints and their ids."
  value       = module.eventhub.private_endpoint_ids
}
