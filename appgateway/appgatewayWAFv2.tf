
resource "azurerm_public_ip" "example" {
  name                = "appgw-public-ip"
  resource_group_name = var.azure_resource_group
  location            = var.location
  allocation_method   = "Static"
  sku = "Standard"
  availability_zone = "No-Zone"
}

#&nbsp;since these variables are re-used - a locals block makes this more maintainable
locals {
  backend_address_pool_name      = "aks-backend-pool"
  frontend_port_name             = "frontend-port"
  frontend_ip_configuration_name = "frontend-ip-config"
  http_setting_name              = "test-http-settings"
  listener_name                  = "test-listener"
  request_routing_rule_name      = "test-routing-rule"
  redirect_configuration_name    = "test-redirect-config"
}

resource "azurerm_application_gateway" "network" {
  name                = "test-appgateway"
  resource_group_name = var.azure_resource_group
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "test-gateway-ip-configuration"
    subnet_id = azurerm_subnet.subnet.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_port {
    name = "port_443"
    port = "443"
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.example.id
  }

  backend_address_pool {
    name         = local.backend_address_pool_name
    ip_addresses = ["10.6.8.50"]
  }

  backend_http_settings {
    name                  = "demo.ruetoj.ml"
    port                  = "80"
    protocol              = "Http"
    cookie_based_affinity = "Disabled"
    request_timeout       = "20"
    path                  = ""
    probe_name            = "health-probe"
    host_name             = "demo.ruetoj.ml"
  }


  http_listener {
    name                           = "demo.ruetoj.ml"
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
    host_name                      = "demo.ruetoj.ml"
    require_sni                    = false
  }

  probe {
    name                = "health-probe"
    protocol            = "Http"
    path                = "/"
    host                = "demo.ruetoj.ml"
    interval            = "30"
    timeout             = "30"
    unhealthy_threshold = "3"
    minimum_servers     = "0"
    match {
      status_code = [
        "200-403",
      ]
    }
  }

  request_routing_rule {
    name                       = "demo.ruetoj.ml"
    rule_type                  = "Basic"
    http_listener_name         = "demo.ruetoj.ml"
    backend_address_pool_name  =  local.backend_address_pool_name
    backend_http_settings_name = "demo.ruetoj.ml"
  }


  backend_http_settings {
    name = "test.site.com"
    port = "80"
    protocol = "Http"
    cookie_based_affinity = "Disabled"
    request_timeout = "20"
    path = ""
    probe_name = "health-probe"
    host_name = "test.site.com"
  }

  http_listener {
    name = "test.site.com"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name = "frontend-port"
    protocol = "Http"
    host_name = "test.site.com"
    require_sni = false
  }

  ssl_certificate {
	 name = "test-site-exported"
	 data = filebase64("test-site.pfx")
	 password = "your-pass"
	}

  http_listener {
    name = "https-test.site.com"
    frontend_ip_configuration_name = "frontend-ip-config"
    frontend_port_name = "port_443"
    protocol = "Https"
    host_name = "test.site.com"
    ssl_certificate_name = "sls-ch-exported"
    require_sni = true
  }

  request_routing_rule { 
	 name = "https-test.site.com"
	 rule_type = "Basic"
	 http_listener_name = "https-test.site.com"
	 backend_address_pool_name = local.backend_address_pool_name
	 backend_http_settings_name = "test.site.com"
	 }

  request_routing_rule { 
	 name = "test.site.com"
	 rule_type = "Basic"
	 http_listener_name = "test.site.com"
   redirect_configuration_name = "redirect-config-https"
	}

  # Request Configuration for Https
  redirect_configuration {
    name                 = "redirect-config-https"
    target_listener_name = "https-test.site.com"
    redirect_type        = "Permanent"
  }


}

