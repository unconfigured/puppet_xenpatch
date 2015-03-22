Overview
========

This is a puppet resource plugin, that allows to manage patches on xenserver. It is my first try to get in touch with puppet (and ruby), but I think, it works pretty well and can be usabe to others. It is possible to apply (xe patch-apply)  patches after deployment (patch-upload), but as shown in the manifest, I leave it up to the next reboot, where an init script picks up all patches and applies them (and, of cause reboots when needed). So if you want to serve your patches from a central point, want puppet to be able to enumerate your patch status and want puppet to prepere you systems with new patches - this could be your starting point.


Usage
=====

At first you need more swap (or ram) in your dom0. I've simply created another swapfile in /var/swap on doublicated my swapspace. Otherwise puppet will fail to add the patches to your system.


After this is done, decide how the patches will be made available to your xenserver. I have just deployed them from the puppets internal file-store (an fetch them with puppet:/// in the source url). Maybe other urls will work, maybe not. But it should be easy to implement them.
To get all currently available patches, cd in the files folder and run "get.sh" to download all patches (Maybe implent a cron job?). After that is done, go to the manifet file and choose the patches you want to apply. The less patches you choose here, the better (and faster) it is for swap and diskspace... Have a look at the xen docs, most patches contain other patches. The initscript shipped with this plugin applies the scripts in numeric sorted order - for my tests it seams like this is fine.


Where to go from here?
======================

As i've said, this is my first touch with puppet, but try to have a look at what you can do with resources, for example, enumerate all patches on your system by simply doing a "puppet resource xenpatch" on you puppet client.
Also have a look at the small facts module that comes with this plugin, it will provide you with a very simple xen_hostuuid fact - for example. Also there is an commented part, which shows, how to get all patches as hashes in facter. It was a first try which is not needed anymore. But it might help someone ;)


What was helpfull to me?
========================
It seams there is not very much documentation about writing puppet resource modules. Or at least not enough for absolute beginners. Maybe one day I will make a short documentation about what I have learned about doing such modules. But for now try it with these docs from other people.
- https://docs.puppetlabs.com/guides/custom_types.html
- https://docs.puppetlabs.com/guides/provider_development.html
- https://docs.puppetlabs.com/guides/complete_resource_example.html
- http://garylarizza.com/blog/2013/11/25/fun-with-providers/
- http://garylarizza.com/blog/2013/12/15/seriously-what-is-this-provider-doing/
- http://www.masterzen.fr/2011/11/02/puppet-extension-point-part-2/
- and of course: /usr/share/ruby/vendor_ruby/puppet


Feel free to fork and improve!
