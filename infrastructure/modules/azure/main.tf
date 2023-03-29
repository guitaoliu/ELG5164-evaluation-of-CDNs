locals {
  storage_account_name = "elg5164terraformawss3bucket"
  container_name       = "public"
}

resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West US"
}

resource "azurerm_storage_account" "example" {
  name                     = local.storage_account_name
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "example" {
  name                  = local.container_name
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "blob"
}

resource "azurerm_cdn_profile" "example" {
  name                = "example-cdn-profile"
  location            = "global"
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "Standard_Microsoft"
}

resource "azurerm_cdn_endpoint" "example" {
  name                          = "example-cdn-endpoint"
  location                      = "global"
  resource_group_name           = azurerm_resource_group.example.name
  profile_name                  = azurerm_cdn_profile.example.name
  origin_host_header            = "${local.storage_account_name}.blob.core.windows.net"
  origin_path                   = "/${local.container_name}"
  is_http_allowed               = false
  is_https_allowed              = true
  querystring_caching_behaviour = "IgnoreQueryString"

  delivery_rule {
    name  = "defaultCacheBehavior"
    order = 1
    cache_expiration_action {
      behavior = "Override"
      duration = "1.50:00:00"
    }
  }

  delivery_rule {
    name  = "minTtl"
    order = 2
    cache_expiration_action {
      behavior = "Override"
      duration = "1.00:00:00"
    }
  }

  delivery_rule {
    name  = "maxTtl"
    order = 3
    cache_expiration_action {
      behavior = "Override"
      duration = "2.00:00:00"
    }
  }

  delivery_rule {
    name  = "compress"
    order = 4
    cache_key_query_string_action {
      behavior = "ExcludeAll"
    }
  }

  content_types_to_compress = [
    "text/html",
    "text/plain",
    "text/xml",
    "application/javascript",
    "application/json",
    "application/xml",
    "text/css",
    "image/svg+xml",
  ]


  global_delivery_rule {
    cache_expiration_action {
      behavior = "Override"
      duration = "1.50:00:00"
    }
  }

  custom_domain_https_configuration {
    certificate_source = "Cdn"
    protocol_type      = "ServerNameIndication"
  }
}

resource "azurerm_storage_account_network_rules" "example" {
  resource_group_name  = azurerm_resource_group.example.name
  storage_account_name = azurerm_storage_account.example.name

  default_action             = "Deny"
  virtual_network_subnet_ids = []
  bypass                     = ["AzureServices"]
}

data "azurerm_storage_account_blob_container_sas" "example" {
  connection_string = azurerm_storage_account.example.primary_connection_string
  container_name    = azurerm_storage_container.example.name

  https_only = true

  start  = "2023-04-01T00:00:00Z"
  expiry = "2023-04-02T00:00:00Z"

  permissions {
    read   = true
    add    = false
    create = false
    write  = false
    delete = false
    list   = false
  }
}
