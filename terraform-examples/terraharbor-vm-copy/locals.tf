locals {
  resource_tags = merge({
    course = "HEIG-VD-PDG-2025"
    app    = var.app_name
  }, var.extra_resource_tags)
}
