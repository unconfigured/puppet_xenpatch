Puppet::Type.type(:xenpatch).provide :xe do
  desc "Local XenServer provider to apply patches"

  confine :operatingsystem => [:XenServer]
  commands :xe => "/opt/xensource/bin/xe",
           :unzip => "/usr/bin/unzip"

  public
  def self.instances
    ## Returns all instances of this type"
    instances = Array.new
    xe('patch-list', '--minimal').split(',').each do |patch|
      patch.chomp!
      next if patch.empty?
      info = self.xe_patch_list("uuid=#{patch}")
      info[:name] = info[:name_label]
      Puppet.debug info
      instances << self.new(info)
    end
    return instances
  end

  public
  def self.prefetch(resources)
    instances.each do |prov|
      if resource = resources[prov.name]
        resource.provider = prov
      end
    end
  end

  public
  def checkuri (path)
    ## Check whether we support the URI presented
    ## in 'source'.
    uri = URI.parse(URI.escape(path))
    unless uri.absolute?
      raise Puppet::ParseError,
        ("Cannot use relative URLs '#{path}'")
    end
    unless uri.hierarchical?
      raise Puppet::ParseError,
        ("Cannot use opaque URLs '#{path}'")
      end
    unless %w{puppet}.include?(uri.scheme)
      raise Puppet::ParseError,
        ("Cannot use URIs of type '#{uri.scheme}'")
    end
    return true
  end

  private
  def getfile (tmpdir, url)
    ## Retrival of 'source'
    Puppet.info "loading patchfile from #{url}"
    content = Puppet::FileServing::Content.indirection.find(url)
    if content.nil?
      raise "Cannot retrieve '#{url}'"
    end
    zip="#{tmpdir}/#{@resource[:name]}.zip"
    File.open("#{zip}", 'w') do |f|
      f.binmode
      f.write(content.content)
      f.close
    end
    content=nil
    Puppet.info "Patchfile written to #{zip}"
    zip
  end

  public
  def patch_get
    ## Provider independend wrapper, in this case to
    ## xe_patch_upload
    xe_patch_upload
  end

  def xe_patch_upload
    ## Take a zip containing the patch, extracts it to a
    ## temporary location and calls xe patch-upload on it.

    path = "#{@resource[:source]}/#{@resource[:name]}.zip"

    Dir.mktmpdir { |dir|

      unless Puppet::Util.absolute_path?(path)
        checkuri(path)
        # Set path to the location of the fetched file
        path = getfile(dir, path)
      end

      unless File.exists?(path)
        raise Puppet::ParseError, ("File does not exists '#{path}'")
      end
  
      xsupdate="#{dir}/#{@resource[:name]}.xsupdate"
      unzip(path, "-d", "#{dir}/")
      patch_uuid = xe('patch-upload', "file-name=#{xsupdate}")
      Puppet.debug "xe patch upload reports: #{patch_uuid}"

      props = self.class.xe_patch_list("uuid=#{patch_uuid.strip}")
      @property_hash.update(props)
      @property_hash[:ensure] = :present
    }
  end

  public
  def patch_apply
    ## Provider independend wrapper, in this case to
    ## xe_patch_apply
    xe_patch_apply
    @property_hash[:ensure] = :applied
  end

  private
  def xe_patch_apply
    hostuuid = Facter.value('xen_hostuuid')
    o = xe('patch-apply', "uuid=#{@property_hash[:uuid]}", "host-uuid=#{hostuuid}")
    Puppet.debug "xe patch upload reports: #{o}"
  end

  private
  def self.xe_patch_list(criteria)
    output = xe('patch-list', criteria)
    props = Hash.new
    output.lines.each do |line|
      line.chomp!
      next if line.empty?
      key, val = line.split(/:/, 2)
      key = key.sub(/\(.+\)/, "").strip
      key = key.tr("-", "_")
      val.strip!
      unless val.nil?
        props[key.to_sym] = val
      end
    end
    return props
  end

  # Auto generate the propertys from @property_hash
  # i.e. def xyz { @property_hash[:xyz] || :absend }
  mk_resource_methods

end
