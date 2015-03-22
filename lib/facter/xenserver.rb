
#Facter.add('xen_updates') do
#
#  confine :operatingsystem => [:XenServer]
#  #commands :xe => "/opt/xensource/bin/xe"
#
#  setcode do
#
#    output = Facter::Core::Execution.exec('xe patch-list')
#    update_hash = Hash.new
#
#    output.lines.each do |line|
#
#      line.chomp!
#      next if line.empty?
#
#      key, val = line.split(/:/, 2)
#      key = key.sub(/\(.+\)/, "").strip
#      if key == "uuid" then
#        uuid = val.strip
#        # Puppet.notice($uuid)
#        update_hash[uuid] = Hash.new
#      else
#        update_hash[uuid][key.strip] = val.strip
#      end
#
#    end
#    update_hash
#  end
#end

Facter.add('xen_hostuuid') do
  setcode do
    output = Facter::Core::Execution.exec("xe host-list --minimal")
    output
  end
end
