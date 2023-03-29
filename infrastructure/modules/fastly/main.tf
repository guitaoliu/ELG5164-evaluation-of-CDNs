provider "fastly" {}

resource "fastly_service_v1" "fastly_service" {
  name = "elg5164-terraform-fastly-service"

  domain {
    name = "elg5164.gtliu.com"
  }

  backend {
    address = module.cdn.cloudfront_distribution_domain_name
    name    = "elg5164-terraform-fastly-service-backend"
    port    = 443
  }

  default_host = module.cdn.cloudfront_distribution_domain_name

  force_destroy = true

  settings {
    default_ttl = 5400
  }

  gzip {
    name          = "gzip_settings"
    content_types = ["text/html", "text/plain", "text/xml", "application/javascript", "application/json", "application/xml", "text/css", "image/svg+xml"]
    extensions    = ["html", "js", "css", "json", "xml", "svg"]
  }

  condition {
    name      = "request_condition_for_cache"
    type      = "REQUEST"
    statement = "req.method == \"GET\" || req.method == \"HEAD\""
  }

  cache_setting {
    name                       = "cache_settings"
    action                     = "cache"
    ttl                        = 5400
    stale_ttl                  = 0
    use_stale_while_revalidate = false
    use_stale_if_error         = false
    condition                  = "request_condition_for_cache"
  }

  request_setting {
    name                 = "request_settings"
    max_stale_age        = 0
    default_host         = module.cdn.cloudfront_distribution_domain_name
    x_forwarded_for      = "clear"
    timer_support        = true
    via_response_headers = true
    condition            = "request_condition_for_cache"
  }
}

output "fastly_service_domain" {
  value = fastly_service_v1.fastly_service.domain[0].name
}

output "fastly_service_cname" {
  value = fastly_service_v1.fastly_service.cloned_version[0].backend[0].address
}
