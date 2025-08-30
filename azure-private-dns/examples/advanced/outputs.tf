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

output "dns_forwarding_rulesets" {
  description = "The DNS forwarding rulesets"
  value       = module.private_dns.dns_forwarding_rulesets
}

output "all_dns_records" {
  description = "All DNS records created"
  value = {
    a_records     = module.private_dns.a_records
    aaaa_records  = module.private_dns.aaaa_records
    cname_records = module.private_dns.cname_records
    mx_records    = module.private_dns.mx_records
    srv_records   = module.private_dns.srv_records
    txt_records   = module.private_dns.txt_records
  }
}
