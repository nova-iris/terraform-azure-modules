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

output "dns_resolver_id" {
  description = "The ID of the DNS Resolver"
  value       = module.private_dns.dns_resolver_id
}

output "dns_resolver_inbound_endpoint_id" {
  description = "The ID of the DNS Resolver inbound endpoint"
  value       = module.private_dns.dns_resolver_inbound_endpoint_id
}

output "dns_resolver_outbound_endpoint_id" {
  description = "The ID of the DNS Resolver outbound endpoint"
  value       = module.private_dns.dns_resolver_outbound_endpoint_id
}

output "dns_forwarding_ruleset_ids" {
  description = "The DNS forwarding ruleset IDs"
  value       = module.private_dns.dns_forwarding_ruleset_ids
}

output "all_dns_record_ids" {
  description = "All DNS record IDs created"
  value = {
    a_record_ids     = module.private_dns.a_record_ids
    aaaa_record_ids  = module.private_dns.aaaa_record_ids
    cname_record_ids = module.private_dns.cname_record_ids
    mx_record_ids    = module.private_dns.mx_record_ids
    srv_record_ids   = module.private_dns.srv_record_ids
    txt_record_ids   = module.private_dns.txt_record_ids
  }
}
