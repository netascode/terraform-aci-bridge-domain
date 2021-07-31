terraform {
  required_providers {
    test = {
      source = "terraform.io/builtin/test"
    }

    aci = {
      source  = "netascode/aci"
      version = ">=0.2.0"
    }
  }
}

resource "aci_rest" "fvTenant" {
  dn         = "uni/tn-TF"
  class_name = "fvTenant"
}

module "main" {
  source = "../.."

  tenant = aci_rest.fvTenant.content.name
  name   = "BD1"
  vrf    = "VRF1"
}

data "aci_rest" "fvBD" {
  dn = "uni/tn-${aci_rest.fvTenant.content.name}/BD-${module.main.name}"

  depends_on = [module.main]
}

resource "test_assertions" "fvBD" {
  component = "fvBD"

  equal "name" {
    description = "name"
    got         = data.aci_rest.fvBD.content.name
    want        = module.main.name
  }
}

data "aci_rest" "fvRsCtx" {
  dn = "${data.aci_rest.fvBD.id}/rsctx"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsCtx" {
  component = "fvRsCtx"

  equal "tnFvCtxName" {
    description = "tnFvCtxName"
    got         = data.aci_rest.fvRsCtx.content.tnFvCtxName
    want        = "VRF1"
  }
}
