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

dns = Fog::DNS.new(
  provider: 'AzureRM',
  tenant_id: azure_credentials['tenant_id'],
  client_id: azure_credentials['client_id'],
  client_secret: azure_credentials['client_secret'],
  subscription_id: azure_credentials['subscription_id']
)

########################################################################################################################
######################                                 Prerequisites                              ######################
########################################################################################################################

rs.resource_groups.create(
  name: 'TestRG-ZN',
  location: 'eastus'
)

########################################################################################################################
######################                                Create Zone                                 ######################
########################################################################################################################

dns.zones.create(
  name: 'test-zone.com',
  resource_group: 'TestRG-ZN'
)

########################################################################################################################
######################                    Get All Zones in a Subscription                         ######################
########################################################################################################################

dns.zones.each do |z|
  puts "Resource Group:#{z.resource_group} name:#{z.name}"
end

########################################################################################################################
######################               Get and Destroy Zone in a Resource Group                     ######################
########################################################################################################################

zone = dns.zones.get('test-zone.com', 'TestRG-ZN')
zone.destroy

########################################################################################################################
######################                                   CleanUp                                  ######################
########################################################################################################################

rg = rs.resource_groups.get('TestRG-ZN')
rg.destroy
