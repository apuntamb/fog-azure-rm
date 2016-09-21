require 'fog/azurerm'
require 'yaml'

########################################################################################################################
######################                   Services object required by all actions                  ######################
######################                              Keep it Uncommented!                          ######################
########################################################################################################################

azure_credentials = YAML.load_file('credentials/azure.yml')

rs = Fog::Resources::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

network = Fog::Network::AzureRM.new(
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

resource_group = rs.resource_groups.create(
  name: 'TestRG-VN',
  location: 'eastus'
)

########################################################################################################################
######################                   Check Virtual Network name Availability                  ######################
########################################################################################################################

network.virtual_networks.check_if_exists('testVnet', 'TestRG-VN')

########################################################################################################################
######################            Create Virtual Network with complete parameters list            ######################
########################################################################################################################

network.virtual_networks.create(
  name:             'testVnet',
  location:         'eastus',
  resource_group:   resource_group.name,
  subnets:          [{
    name: 'mysubnet',
    address_prefix: '10.1.0.0/24'
  }],
  dns_servers:       %w(10.1.0.0 10.2.0.0),
  address_prefixes:  %w(10.1.0.0/16 10.2.0.0/16)
)

########################################################################################################################
######################                      List Virtual Network                       #################################
########################################################################################################################

network.virtual_networks(resource_group: resource_group.name)

########################################################################################################################
######################                      Get Virtual Network                       ##################################
########################################################################################################################

vnet = network.virtual_networks.get('TestRG-VN', 'testvnet')

########################################################################################################################
######################                Add/Remove DNS Servers to/from Virtual Network           #########################
########################################################################################################################

vnet.add_dns_servers(%w(10.3.0.0 10.4.0.0))

vnet.remove_dns_servers(%w(10.3.0.0 10.4.0.0))

########################################################################################################################
######################                Add/Remove Address Prefixes to/from Virtual Network      #########################
########################################################################################################################

vnet.add_address_prefixes(%w(10.2.0.0/16 10.3.0.0/16))

vnet.remove_address_prefixes(['10.2.0.0/16'])

########################################################################################################################
######################                Add/Remove Subnets to/from Virtual Network           #############################
########################################################################################################################

vnet.add_subnets(
  [
    {
      name: 'test-subnet',
      address_prefix: '10.3.0.0/24'
    }
  ]
)

vnet.remove_subnets(['test-subnet'])

########################################################################################################################
######################                Update Virtual Network                                  ##########################
########################################################################################################################

vnet.update(
  subnets:
    [
      {
        name: 'fog-subnet',
        address_prefix: '10.3.0.0/16'
      }
    ],
  dns_servers: %w(10.3.0.0 10.4.0.0)
)

########################################################################################################################
######################                List Free IP Address count in Subnets                   ##########################
########################################################################################################################

vnet.subnets.each do |subnet|
  Fog::Logger.debug network.subnets.get('TestRG-VN', 'testVnet', subnet.name).get_available_ipaddress_count
end

########################################################################################################################
######################                Destroy Virtual Network                                  #########################
########################################################################################################################

vnet.destroy

########################################################################################################################
######################                                   CleanUp                                  ######################
########################################################################################################################

resource_group.destroy
