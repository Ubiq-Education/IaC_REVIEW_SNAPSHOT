locals {
  # IMPORTANT: AMAIS and DXP web app subnet names must end in '-<guid-fragment>'
  # where <guid-fragment> is the first 8 character segment of the subscription id where the web apps are located
  network_scheme = {
    canadacentral = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.88.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.88.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        dxp-01 = {
          address_space = ["10.200.8.0/23"]
          subnets = {
            dxp-01-c94f8a3d = {
              address_prefixes        = ["10.200.8.0/23"]
              service_delegation_name = local.dxp_sub_delegation
              service_endpoints       = local.dxp_sub_service_endpoints
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.160.0/21"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.160.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-9aaae1e7 = {
              address_prefixes        = ["10.100.161.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-eb8da73f = {
              address_prefixes        = ["10.100.162.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.163.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.164.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.165.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.166.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
    } }
    canadaeast = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.56.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.56.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.96.0/21"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.96.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    centralindia = {
      vnets = {
        hub = {
          nat_gateway                        = true
          nat_gateway_pip_count              = 1
          nat_gateway_used_for_secure_access = true
          address_space                      = ["10.0.10.0/24"]
          subnets = {
            twingate-ci = {
              address_prefixes        = ["10.0.10.0/27"]
              associate_nat_gateway   = true
              service_delegation_name = local.twingate_sub_delegation
              service_endpoints       = local.twingate_sub_service_endpoints
            }
          }
        }
        amais-central-01 = {
          address_space = ["10.150.32.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.32.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.192.0/21"]
          subnets = {
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.192.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    centralus = {
      vnets = {
        hub = {
          nat_gateway                        = true
          nat_gateway_pip_count              = 1
          nat_gateway_used_for_secure_access = true
          address_space                      = ["10.0.20.0/24"]
          subnets = {
            twingate-ci = {
              address_prefixes        = ["10.0.20.0/27"]
              associate_nat_gateway   = true
              service_delegation_name = local.twingate_sub_delegation
              service_endpoints       = local.twingate_sub_service_endpoints
            }
          }
        }
        amais-central-01 = {
          address_space = ["10.150.136.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.136.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        dxp-01 = {
          address_space = ["10.200.4.0/23"]
          subnets = {
            dxp-01-c94f8a3d = {
              address_prefixes        = ["10.200.4.0/23"]
              service_delegation_name = local.dxp_sub_delegation
              service_endpoints       = local.dxp_sub_service_endpoints
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.64.0/21"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.64.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-9aaae1e7 = {
              address_prefixes        = ["10.100.65.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-eb8da73f = {
              address_prefixes        = ["10.100.66.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.67.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.68.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.69.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.70.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
        cae-hd-01 = {
          address_space = ["172.16.32.0/21"]
          subnets = {
            amais-hd-01 = {
              address_prefixes        = ["172.16.32.0/23"]
              service_delegation_name = local.cae_sub_delegation
              service_endpoints       = local.cae_sub_service_endpoints
            }
          }
        }
      }
    }
    eastus = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.120.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.120.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.16.0/21"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.16.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-9aaae1e7 = {
              address_prefixes        = ["10.100.17.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-eb8da73f = {
              address_prefixes        = ["10.100.18.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.19.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.20.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    eastus2 = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.144.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.144.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.32.0/21"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.32.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-9aaae1e7 = {
              address_prefixes        = ["10.100.33.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-eb8da73f = {
              address_prefixes        = ["10.100.34.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.35.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.36.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.37.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.38.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    germanywestcentral = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.104.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.104.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        dxp-01 = {
          address_space = ["10.200.12.0/23"]
          subnets = {
            dxp-01-c94f8a3d = {
              address_prefixes        = ["10.200.12.0/23"]
              service_delegation_name = local.dxp_sub_delegation
              service_endpoints       = local.dxp_sub_service_endpoints
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.112.0/21"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.112.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-9aaae1e7 = {
              address_prefixes        = ["10.100.113.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-eb8da73f = {
              address_prefixes        = ["10.100.114.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.115.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.116.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.117.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.118.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    koreacentral = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.48.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.48.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.184.0/21"]
          subnets = {
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.184.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.185.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.186.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    northeurope = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.8.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.8.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
      }
    }
    southcentralus = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.96.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.96.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.80.0/21"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.80.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-9aaae1e7 = {
              address_prefixes        = ["10.100.81.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-eb8da73f = {
              address_prefixes        = ["10.100.82.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.83.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.84.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.85.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.86.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    southeastasia = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.64.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.64.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.176.0/21"]
          subnets = {
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.176.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.177.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.178.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.179.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    swedencentral = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.24.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.24.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
      }
    }
    switzerlandnorth = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.80.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.80.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.128.0/22"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.128.0/26"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-9aaae1e7 = {
              address_prefixes        = ["10.100.128.128/26"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-eb8da73f = {
              address_prefixes        = ["10.100.129.0/26"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.129.128/26"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.130.0/26"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.130.128/26"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.131.0/26"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
        cae-hd-01 = {
          address_space = ["172.16.0.0/21"]
          subnets = {
            amais-hd-01 = {
              address_prefixes        = ["172.16.0.0/23"]
              service_delegation_name = local.cae_sub_delegation
              service_endpoints       = local.cae_sub_service_endpoints
            }
          }
        }
      }
    }
    uaenorth = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.128.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.128.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        dxp-01 = {
          address_space = ["10.200.16.0/23"]
          subnets = {
            dxp-01-c94f8a3d = {
              address_prefixes        = ["10.200.16.0/23"]
              service_delegation_name = local.dxp_sub_delegation
              service_endpoints       = local.dxp_sub_service_endpoints
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.144.0/21"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.144.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-9aaae1e7 = {
              address_prefixes        = ["10.100.145.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-eb8da73f = {
              address_prefixes        = ["10.100.146.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.147.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.148.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.149.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.150.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    uksouth = {
      vnets = {
        hub = {
          nat_gateway                        = true
          nat_gateway_pip_count              = 1
          nat_gateway_used_for_secure_access = true
          address_space                      = ["10.0.15.0/24"]
          role_assignments = {
            "b2678499-5ec0-4a1f-b15c-bf0b28b2917e" = {
              # DevOpsInfrastructure SPN
              role_names = ["Network Contributor", "Reader"]
            }
          }
          subnets = {
            twingate-ci = {
              address_prefixes        = ["10.0.15.0/27"]
              associate_nat_gateway   = true
              service_delegation_name = local.twingate_sub_delegation
              service_endpoints       = local.twingate_sub_service_endpoints
            }
            terraform-agents-ci = {
              address_prefixes        = ["10.0.15.64/27"]
              associate_nat_gateway   = true
              service_delegation_name = local.terraform_sub_delegation
              service_endpoints       = local.terraform_sub_service_endpoints
            }
            devops-agent-pool-01 = {
              address_prefixes        = ["10.0.15.128/27"]
              associate_nat_gateway   = true
              service_delegation_name = local.devops_sub_delegation
              service_endpoints       = local.devops_sub_service_endpoints
            }
            devops-agent-pool-02 = {
              address_prefixes        = ["10.0.15.160/27"]
              associate_nat_gateway   = true
              service_delegation_name = local.devops_sub_delegation
              service_endpoints       = local.devops_sub_service_endpoints
            }
            ubiq-corp-01 = {
              address_prefixes        = ["10.0.15.192/27"]
              associate_nat_gateway   = true
              service_delegation_name = "Microsoft.Web/serverFarms"
              service_endpoints       = [ "Microsoft.KeyVault", "Microsoft.Web", "Microsoft.CognitiveServices"]
            }
          }
        }
        amais-central-01 = {
          address_space = ["10.150.0.0/21"]
          subnets = {
            central-functions-01 = {
              address_prefixes        = ["10.150.0.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault"]
            }
            central-functions-02 = {
              address_prefixes        = ["10.150.0.64/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub", "Microsoft.CognitiveServices"]
            }
            central-functions-03 = {
              address_prefixes        = ["10.150.0.128/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub", "Microsoft.CognitiveServices"]
            }
            central-functions-04 = {
              address_prefixes        = ["10.150.0.192/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub", "Microsoft.CognitiveServices", "Microsoft.AzureCosmosDB"]
            }
            central-functions-05 = {
              address_prefixes        = ["10.150.1.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        dxp-01 = {
          address_space = ["10.200.0.0/23"]
          subnets = {
            dxp-01-c94f8a3d = {
              address_prefixes        = ["10.200.0.0/23"]
              service_delegation_name = local.dxp_sub_delegation
              service_endpoints       = local.dxp_sub_service_endpoints
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.0.0/21"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.0.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-9aaae1e7 = {
              address_prefixes        = ["10.100.1.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-eb8da73f = {
              address_prefixes        = ["10.100.2.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.3.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.4.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.5.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.6.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    ukwest = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.72.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.72.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
      }
    }
    westeurope = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.40.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.40.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
      }
    }
    westus2 = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.112.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.112.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
        amais-01 = {
          address_space = ["10.100.48.0/21"]
          subnets = {
            amais-01-c94f8a3d = {
              address_prefixes        = ["10.100.48.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-9aaae1e7 = {
              address_prefixes        = ["10.100.49.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-eb8da73f = {
              address_prefixes        = ["10.100.50.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-7e237fe5 = {
              address_prefixes        = ["10.100.51.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-1b4d74e1 = {
              address_prefixes        = ["10.100.52.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-8fdf2945 = {
              address_prefixes        = ["10.100.53.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
            amais-01-3d095edb = {
              address_prefixes        = ["10.100.54.0/25"]
              service_delegation_name = local.amais_sub_delegation
              service_endpoints       = local.amais_sub_service_endpoints
            }
          }
        }
      }
    }
    westus3 = {
      vnets = {
        amais-central-01 = {
          address_space = ["10.150.16.0/21"]
          subnets = {
            central-functions-05 = {
              address_prefixes        = ["10.150.16.0/26"]
              service_delegation_name = local.flex_consumption_sub_delegation
              service_endpoints       = ["Microsoft.KeyVault", "Microsoft.Web", "Microsoft.EventHub"]
            }
          }
        }
      }
    }
  }
}
