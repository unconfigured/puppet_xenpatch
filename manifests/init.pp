class xenupdate (
  # See http://support.citrix.com/article/CTX138115#XenServer%206.2
  $updates = [    'XS62ESP1', 'XS62ESP1009', 'XS62ESP1012',
               'XS62ESP1014', 'XS62ESP1016', 'XS62ESP1017', 'XS62ESP1019' ]
) {

  # Install initscript to apply patches
  file { "/etc/init.d/xenpatch":
    ensure => present,
    mode => 0755,
    source => 'puppet:///modules/xenupdate/initscript.sh'
  }

  # Updatescript to apply patches on reboot and do
  # further reboots when needed
  file { "/etc/rc3.d/S97xenpatch":
    ensure => link,
    target => '../init.d/xenpatch'
  }

  # Patches should be only present and will be
  # applied on system restarts
  xenpatch { $updates:
    source => 'puppet:///modules/xenupdate',
    ensure => 'present'
  }
}
