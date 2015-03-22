require 'puppet/parameter/boolean'

Puppet::Type.newtype(:xenpatch) do

  @doc = %q{Upload and apply patches to XenServer.

    Example:
    
       xenpatch { 'XS62ESP1':
         source => 'puppet:///modules/xenpatch',
         apply  => false
       }
  }

  def instances
    []
  end

  ensurable do
    # Remember: Values get only called, when insync=false
    # So we do not need to check everything again...

    # Patch is uploaded but not applied
    newvalue(:present) do
      # The patch is downloaded from it's source and ready to
      # be applied.
      provider.patch_get
    end

    # Path is applied
    newvalue(:applied) do
      # The patch applied to the system, all action from the
      # after-apply guidance should be done manually

      current_value = self.retrieve
      if [nil, :absent].include?(current_value)
        provider.patch_get
      end
      provider.patch_apply
    end

    # Get current status
    def retrieve
      if ( provider.hosts != :absent &&
           provider.hosts == Facter.value('xen_hostuuid') )
        :applied
      elsif ( provider.uuid != :absent )
        :present
      else
        :absent
      end
    end

    # Check if we are already done
    def insync?(is)
      case should
      when :applied
        return [:applied].include?(is)
      when :present
        return [:applied,:present].include?(is)
      when :absent
        return [:absent]
      end
    end
  end

  newparam(:name) do
    desc "Name of the patch"
    isnamevar
  end

  newparam(:source) do
    desc "Source of the path, can be puppet:// to fetch from server"
    validate do |value|
      super if provider.checkuri(value)
    end
  end

  newparam(:clearafter, :boolean => true, :parent => Puppet::Parameter::Boolean) do
    desc "Should the patch be remove from filesystem when applied?"
    defaultto true
  end

  # Properties of a patch
  newproperty(:uuid)
  newproperty(:name_label)
  newproperty(:name_description)
  newproperty(:size)
  newproperty(:hosts)
  newproperty(:after_apply_guidance)

end
