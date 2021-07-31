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

  tenant                     = aci_rest.fvTenant.content.name
  name                       = "BD1"
  alias                      = "BD1-ALIAS"
  description                = "My Description"
  arp_flooding               = true
  advertise_host_routes      = true
  ip_dataplane_learning      = false
  limit_ip_learn_to_subnets  = false
  mac                        = "11:11:11:11:11:11"
  l3_multicast               = true
  multi_destination_flooding = "drop"
  unicast_routing            = false
  unknown_unicast            = "flood"
  unknown_ipv4_multicast     = "opt-flood"
  unknown_ipv6_multicast     = "opt-flood"
  vrf                        = "VRF1"
  subnets = [{
    description        = "Subnet Description"
    ip                 = "1.1.1.1/24"
    primary_ip         = true
    public             = true
    shared             = true
    igmp_querier       = true
    nd_ra_prefix       = false
    no_default_gateway = false
  }]
  l3outs = ["L3OUT1"]
  dhcp_labels = [{
    dhcp_relay_policy  = "DHCP_RELAY_1"
    dhcp_option_policy = "DHCP_OPTION_1"
  }]
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

  equal "nameAlias" {
    description = "nameAlias"
    got         = data.aci_rest.fvBD.content.nameAlias
    want        = "BD1-ALIAS"
  }

  equal "descr" {
    description = "descr"
    got         = data.aci_rest.fvBD.content.descr
    want        = "My Description"
  }

  equal "arpFlood" {
    description = "arpFlood"
    got         = data.aci_rest.fvBD.content.arpFlood
    want        = "yes"
  }

  equal "hostBasedRouting" {
    description = "hostBasedRouting"
    got         = data.aci_rest.fvBD.content.hostBasedRouting
    want        = "yes"
  }

  equal "ipLearning" {
    description = "ipLearning"
    got         = data.aci_rest.fvBD.content.ipLearning
    want        = "no"
  }

  equal "limitIpLearnToSubnets" {
    description = "limitIpLearnToSubnets"
    got         = data.aci_rest.fvBD.content.limitIpLearnToSubnets
    want        = "no"
  }

  equal "mac" {
    description = "mac"
    got         = data.aci_rest.fvBD.content.mac
    want        = "11:11:11:11:11:11"
  }

  equal "mcastAllow" {
    description = "mcastAllow"
    got         = data.aci_rest.fvBD.content.mcastAllow
    want        = "yes"
  }

  equal "multiDstPktAct" {
    description = "multiDstPktAct"
    got         = data.aci_rest.fvBD.content.multiDstPktAct
    want        = "drop"
  }

  equal "unicastRoute" {
    description = "unicastRoute"
    got         = data.aci_rest.fvBD.content.unicastRoute
    want        = "no"
  }

  equal "unkMacUcastAct" {
    description = "unkMacUcastAct"
    got         = data.aci_rest.fvBD.content.unkMacUcastAct
    want        = "flood"
  }

  equal "unkMcastAct" {
    description = "unkMcastAct"
    got         = data.aci_rest.fvBD.content.unkMcastAct
    want        = "opt-flood"
  }

  equal "v6unkMcastAct" {
    description = "v6unkMcastAct"
    got         = data.aci_rest.fvBD.content.v6unkMcastAct
    want        = "opt-flood"
  }
}

data "aci_rest" "fvSubnet" {
  dn = "${data.aci_rest.fvBD.id}/subnet-[1.1.1.1/24]"

  depends_on = [module.main]
}

resource "test_assertions" "fvSubnet" {
  component = "fvSubnet"

  equal "ip" {
    description = "ip"
    got         = data.aci_rest.fvSubnet.content.ip
    want        = "1.1.1.1/24"
  }

  equal "descr" {
    description = "descr"
    got         = data.aci_rest.fvSubnet.content.descr
    want        = "Subnet Description"
  }

  equal "preferred" {
    description = "preferred"
    got         = data.aci_rest.fvSubnet.content.preferred
    want        = "yes"
  }

  equal "ctrl" {
    description = "ctrl"
    got         = data.aci_rest.fvSubnet.content.ctrl
    want        = "querier"
  }

  equal "scope" {
    description = "scope"
    got         = data.aci_rest.fvSubnet.content.scope
    want        = "public,shared"
  }
}

data "aci_rest" "fvRsBDToOut" {
  dn = "${data.aci_rest.fvBD.id}/rsBDToOut-L3OUT1"

  depends_on = [module.main]
}

resource "test_assertions" "fvRsBDToOut" {
  component = "fvRsBDToOut"

  equal "tnL3extOutName" {
    description = "tnL3extOutName"
    got         = data.aci_rest.fvRsBDToOut.content.tnL3extOutName
    want        = "L3OUT1"
  }
}

data "aci_rest" "dhcpLbl" {
  dn = "${data.aci_rest.fvBD.id}/dhcplbl-DHCP_RELAY_1"

  depends_on = [module.main]
}

resource "test_assertions" "dhcpLbl" {
  component = "dhcpLbl"

  equal "name" {
    description = "name"
    got         = data.aci_rest.dhcpLbl.content.name
    want        = "DHCP_RELAY_1"
  }
}

data "aci_rest" "dhcpRsDhcpOptionPol" {
  dn = "${data.aci_rest.dhcpLbl.id}/rsdhcpOptionPol"

  depends_on = [module.main]
}

resource "test_assertions" "dhcpRsDhcpOptionPol" {
  component = "dhcpRsDhcpOptionPol"

  equal "tnDhcpOptionPolName" {
    description = "tnDhcpOptionPolName"
    got         = data.aci_rest.dhcpRsDhcpOptionPol.content.tnDhcpOptionPolName
    want        = "DHCP_OPTION_1"
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
