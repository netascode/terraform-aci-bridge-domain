<!-- BEGIN_TF_DOCS -->
[![Tests](https://github.com/netascode/terraform-aci-bridge-domain/actions/workflows/test.yml/badge.svg)](https://github.com/netascode/terraform-aci-bridge-domain/actions/workflows/test.yml)

# Terraform ACI Bridge Domain Module

Manages ACI Bridge Domain

Location in GUI:
`Tenants` » `XXX` » `Networking` » `Bridge Domains`

## Examples

```hcl
module "aci_bridge_domain" {
  source  = "netascode/bridge-domain/aci"
  version = ">= 0.0.2"

  tenant                     = "ABC"
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
    tags = [
      {
        key   = "tag_key"
        value = "tag_value"
      }
    ]
  }]
  l3outs = ["L3OUT1"]
  dhcp_labels = [{
    dhcp_relay_policy  = "DHCP_RELAY_1"
    dhcp_option_policy = "DHCP_OPTION_1"
  }]
}

```

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0.0 |
| <a name="requirement_aci"></a> [aci](#requirement\_aci) | >= 0.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aci"></a> [aci](#provider\_aci) | >= 0.2.0 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_tenant"></a> [tenant](#input\_tenant) | Tenant name. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | Bridge domain name. | `string` | n/a | yes |
| <a name="input_alias"></a> [alias](#input\_alias) | Alias. | `string` | `""` | no |
| <a name="input_description"></a> [description](#input\_description) | Description. | `string` | `""` | no |
| <a name="input_arp_flooding"></a> [arp\_flooding](#input\_arp\_flooding) | ARP flooding. | `bool` | `false` | no |
| <a name="input_advertise_host_routes"></a> [advertise\_host\_routes](#input\_advertise\_host\_routes) | Advertisement of host routes. | `bool` | `false` | no |
| <a name="input_ip_dataplane_learning"></a> [ip\_dataplane\_learning](#input\_ip\_dataplane\_learning) | IP data plane learning. | `bool` | `true` | no |
| <a name="input_limit_ip_learn_to_subnets"></a> [limit\_ip\_learn\_to\_subnets](#input\_limit\_ip\_learn\_to\_subnets) | Limit IP learning to subnets. | `bool` | `true` | no |
| <a name="input_mac"></a> [mac](#input\_mac) | MAC address. Format: `12:34:56:78:9A:BC`. | `string` | `"00:22:BD:F8:19:FF"` | no |
| <a name="input_l3_multicast"></a> [l3\_multicast](#input\_l3\_multicast) | L3 multicast. | `bool` | `false` | no |
| <a name="input_multi_destination_flooding"></a> [multi\_destination\_flooding](#input\_multi\_destination\_flooding) | Multi destination flooding. Choices: `bd-flood`, `encap-flood`, `drop`. | `string` | `"bd-flood"` | no |
| <a name="input_unicast_routing"></a> [unicast\_routing](#input\_unicast\_routing) | Unicast routing. | `bool` | `true` | no |
| <a name="input_unknown_unicast"></a> [unknown\_unicast](#input\_unknown\_unicast) | Unknown unicast forwarding behavior. Choices: `flood`, `proxy`. | `string` | `"proxy"` | no |
| <a name="input_unknown_ipv4_multicast"></a> [unknown\_ipv4\_multicast](#input\_unknown\_ipv4\_multicast) | Unknown IPv4 multicast forwarding behavior. Choices: `flood`, `opt-flood`. | `string` | `"flood"` | no |
| <a name="input_unknown_ipv6_multicast"></a> [unknown\_ipv6\_multicast](#input\_unknown\_ipv6\_multicast) | Unknown IPV6 multicast forwarding behavior. Choices: `flood`, `opt-flood`. | `string` | `"flood"` | no |
| <a name="input_vrf"></a> [vrf](#input\_vrf) | VRF name. | `string` | n/a | yes |
| <a name="input_subnets"></a> [subnets](#input\_subnets) | List of subnets. Default value `primary_ip`: `false`. Default value `public`: `false`. Default value `shared`: `false`. Default value `igmp_querier`: `false`. Default value `nd_ra_prefix`: `true`. Default value `no_default_gateway`: `false`. | <pre>list(object({<br>    description        = optional(string)<br>    ip                 = string<br>    primary_ip         = optional(bool)<br>    public             = optional(bool)<br>    shared             = optional(bool)<br>    igmp_querier       = optional(bool)<br>    nd_ra_prefix       = optional(bool)<br>    no_default_gateway = optional(bool)<br>    tags = optional(list(object({<br>      key   = string<br>      value = string<br>    })))<br>  }))</pre> | `[]` | no |
| <a name="input_l3outs"></a> [l3outs](#input\_l3outs) | List of l3outs | `list(string)` | `[]` | no |
| <a name="input_dhcp_labels"></a> [dhcp\_labels](#input\_dhcp\_labels) | List of DHCP labels | <pre>list(object({<br>    dhcp_relay_policy  = optional(string)<br>    dhcp_option_policy = optional(string)<br>  }))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_dn"></a> [dn](#output\_dn) | Distinguished name of `fvBD` object. |
| <a name="output_name"></a> [name](#output\_name) | Bridge domain name. |

## Resources

| Name | Type |
|------|------|
| [aci_rest.dhcpLbl](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.dhcpRsDhcpOptionPol](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvBD](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsBDToOut](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvRsCtx](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.fvSubnet](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
| [aci_rest.tagTag](https://registry.terraform.io/providers/netascode/aci/latest/docs/resources/rest) | resource |
<!-- END_TF_DOCS -->