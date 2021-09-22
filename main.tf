locals {
  tags_list = flatten([
    for subnet in var.subnets : [
      for tag in subnet.tags != null ? subnet.tags : [] : {
        ip    = subnet.ip
        key   = tag.key
        value = tag.value
      }
    ]
  ])
}

resource "aci_rest" "fvBD" {
  dn         = "uni/tn-${var.tenant}/BD-${var.name}"
  class_name = "fvBD"
  content = {
    name                  = var.name
    nameAlias             = var.alias
    descr                 = var.description
    arpFlood              = var.arp_flooding == true ? "yes" : "no"
    hostBasedRouting      = var.advertise_host_routes == true ? "yes" : "no"
    ipLearning            = var.ip_dataplane_learning == true ? "yes" : "no"
    limitIpLearnToSubnets = var.limit_ip_learn_to_subnets == true ? "yes" : "no"
    mac                   = var.mac
    mcastAllow            = var.l3_multicast == true ? "yes" : "no"
    multiDstPktAct        = var.multi_destination_flooding
    type                  = "regular"
    unicastRoute          = var.unicast_routing == true ? "yes" : "no"
    unkMacUcastAct        = var.unknown_unicast
    unkMcastAct           = var.unknown_ipv4_multicast
    v6unkMcastAct         = var.unknown_ipv6_multicast
  }
}

resource "aci_rest" "fvSubnet" {
  for_each   = { for subnet in var.subnets : subnet.ip => subnet }
  dn         = "${aci_rest.fvBD.id}/subnet-[${each.value.ip}]"
  class_name = "fvSubnet"
  content = {
    ip        = each.value.ip
    descr     = each.value.description != null ? each.value.description : ""
    preferred = each.value.primary_ip == true ? "yes" : "no"
    ctrl      = join(",", concat(each.value.nd_ra_prefix == true || each.value.nd_ra_prefix == null ? ["nd"] : [], each.value.no_default_gateway == true ? ["no-default-gateway"] : [], each.value.igmp_querier == true ? ["querier"] : []))
    scope     = join(",", concat(each.value.public == true ? ["public"] : ["private"], each.value.shared == true ? ["shared"] : []))
  }
}

resource "aci_rest" "tagTag" {
  for_each   = { for item in local.tags_list : "${item.ip}.${item.key}" => item }
  dn         = "${aci_rest.fvSubnet["${each.value.ip}"].id}/tagKey-${each.value.key}"
  class_name = "tagTag"
  content = {
    key   = each.value.key
    value = each.value.value
  }
}

resource "aci_rest" "fvRsBDToOut" {
  for_each   = toset(var.l3outs)
  dn         = "${aci_rest.fvBD.id}/rsBDToOut-${each.value}"
  class_name = "fvRsBDToOut"
  content = {
    tnL3extOutName = each.value
  }
}

resource "aci_rest" "dhcpLbl" {
  for_each   = { for dhcp_label in var.dhcp_labels : dhcp_label.dhcp_relay_policy => dhcp_label }
  dn         = "${aci_rest.fvBD.id}/dhcplbl-${each.value.dhcp_relay_policy}"
  class_name = "dhcpLbl"
  content = {
    owner = "tenant",
    name  = each.value.dhcp_relay_policy
  }
}

resource "aci_rest" "dhcpRsDhcpOptionPol" {
  for_each   = { for dhcp_label in var.dhcp_labels : dhcp_label.dhcp_relay_policy => dhcp_label if dhcp_label.dhcp_option_policy != null }
  dn         = "${aci_rest.dhcpLbl[each.value.dhcp_relay_policy].id}/rsdhcpOptionPol"
  class_name = "dhcpRsDhcpOptionPol"
  content = {
    tnDhcpOptionPolName = each.value.dhcp_option_policy
  }
}

resource "aci_rest" "fvRsCtx" {
  dn         = "${aci_rest.fvBD.id}/rsctx"
  class_name = "fvRsCtx"
  content = {
    tnFvCtxName = var.vrf
  }
}
