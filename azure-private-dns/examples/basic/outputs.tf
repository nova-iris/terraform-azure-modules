output "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone"
  value       = module.private_dns.private_dns_zone_id
}

output "private_dns_zone_name" {
  description = "The name of the Private DNS Zone"
  value       = module.private_dns.private_dns_zone_name
}

output "virtual_network_link_ids" {
  description = "The virtual network link IDs"
  value       = module.private_dns.virtual_network_link_ids
}

output "a_record_ids" {
  description = "The A record IDs created"
  value       = module.private_dns.a_record_ids
}

output "cname_record_ids" {
  description = "The CNAME record IDs created"
  value       = module.private_dns.cname_record_ids
}
