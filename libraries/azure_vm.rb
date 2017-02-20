
require_relative 'common/helpers'

class AzureVm < Inspec.resource(1)
  name 'azure_vm'

  desc "
    This resource gathers information about which image the vm was created from
  "

  example "
    describe azure_vm(host: 'acme-test-01', resource_group: 'ACME') do
      its('sku') { should eq '16.04.0-LTS'}
    end
  "

  attr_accessor :vm

  # Load the configuration file on initialisation
  def initialize(opts)
    opts = opts
    helpers = Helpers.new
    @vm = helpers.get_vm(opts[:host], opts[:resource_group])

    # Ensure that the vm is an object
    raise format('An error has occured: %s', vm) if vm.instance_of?(String)
  end

  # Determine the SKU used to create the machine
  #
  # == Returns:
  # String showing the sku, e.g. 16.04.0-LTS
  #
  def sku
    vm.storage_profile.image_reference.sku
  end

  # Determine the publisher of the SKU
  #
  # == Returns:
  # String of the publisher, e.g. Canonical
  #
  def publisher
    vm.storage_profile.image_reference.publisher
  end

  # Determine the offer from the publisher
  #
  # == Returns:
  # String of the offer, e.g. UbuntuServer
  #
  def offer
    vm.storage_profile.image_reference.offer
  end

  # Determine the size of the machine
  #
  # == Returns:
  # String showing the size of the machine, e.g. Standard_DS1_v2
  #
  def size
    vm.hardware_profile.vm_size
  end

  # Determine the location of the vm
  #
  # == Returns:
  # String representing the location of the machinem, e.g. westeurope
  #
  def location
    vm.location
  end

  # State if boot diagnostics is enabled
  #
  # == Returns:
  # Boolean
  #
  def boot_diagnostics?
    vm.diagnostics_profile.boot_diagnostics.enabled
  end

  # Determine how many network cards are connected to the machine
  #
  # == Returns:
  # Integer
  #
  def nic_count
    vm.network_profile.network_interfaces.length
  end

  # The admin username for the machine
  #
  # == Returns:
  # String of the admin username when the machine was created, e.g. azure
  #
  def username
    vm.os_profile.admin_username
  end

  # The computername as seen by the operating system
  # This might be different to the VM name as seen in Azure
  #
  # == Returns:
  # String of the computername
  #
  def computername
    vm.os_profile.computer_name
  end

  # Alias for computername
  #
  # == Returns:
  # String of the computername
  #
  def hostname
    computername
  end

  # Determine if password authentication is enabled
  # For Windows this is always True.  On Linux this will be determined
  #
  # == Returns:
  # Boolean
  #
  def password_authentication?
    # if the vm has a linux configuration then interrogate that, otherwise return true
    if !vm.os_profile.linux_configuration.nil?
      !vm.os_profile.linux_configuration.disable_password_authentication
    else
      true
    end
  end

  # How many SSH keys have been added to the machine
  # For Windows this will be 0, for Linux this will be determined
  #
  # == Returns:
  # Integer
  #
  def ssh_key_count
    if !vm.os_profile.linux_configuration.nil?
      vm.os_profile.linux_configuration.ssh.public_keys.length
    else
      0
    end
  end

  # Determine the Operating system type using the os_disk object
  #
  # == Returns:
  # String of the OS type, e.g. Windows or Linux
  #
  def os_type
    vm.storage_profile.os_disk.os_type
  end
end