output "private_dns_zone_id" {
  description = "The ID of the Private DNS Zone"
  value       = module.private_dns.private_dns_zone_id
}

output "private_dns_zone_name" {
  description = "The name of the Private DNS Zone"
  value       = module.private_dns.private_dns_zone_name
}

output "virtual_network_links" {
  description = "The virtual network links"
  value       = module.private_dns.virtual_network_links
}

output "a_records" {
  description = "The A records created"
  value       = module.private_dns.a_records
}

output "cname_records" {
  description = "The CNAME records created"
  value       = module.private_dns.cname_records
}
