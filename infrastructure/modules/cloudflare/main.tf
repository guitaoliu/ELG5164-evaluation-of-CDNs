provider "cloudflare" {
  email = "gtliu52@gmail.com"
}

resource "cloudflare_zone" "example" {
  zone = "gtliu.com"
}

locals {
  origin_address = module.cdn.cloudfront_distribution_domain_name
}

resource "cloudflare_record" "example" {
  zone_id = cloudflare_zone.example.id
  name    = "elg5164.gtliu.com"
  type    = "CNAME"
  value   = local.origin_address
  proxied = true
}

resource "cloudflare_page_rule" "cache_rule" {
  zone_id  = cloudflare_zone.example.id
  priority = 1
  status   = "active"

  target = "/*"
  actions {
    cache_level    = "cache_everything"
    edge_cache_ttl = 5400
  }
}
