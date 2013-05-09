# What is MunkiAdmin?

MunkiAdmin is a GUI for managing munki repositories. It is written
with Objective-C and uses in-memory Core Data store as a backend.

So what is munki and what are those munki repositories then? Well,
munki is a set of tools that allow administrators to define managed
installs for client machines. Repositories are served from a standard
web server.

For more information, visit [Munki tools homepage](http://code.google.com/p/munki/)


# Important:

Code _is_ considered stable and it shouldn't have any major issues. However, MunkiAdmin is still alpha and not feature-complete so be prepared to see bugs. If you decide to run this on a production repo, make sure your backups are current or you have some other methods for going back in time. I'm using git version control on my munki repositories so I'll always know what was changed.

You can continue to use your favorite text editor to edit pkginfo files and manifests. MunkiAdmin is designed to complement your current workflow and it doesn't require any configuration or changes to your munki repository.


# How to get MunkiAdmin?

### Download a pre-built version:

Latest version is [MunkiAdmin 0.2.12](https://s3.amazonaws.com/munkiadmin-downloads/public/MunkiAdmin-0.2.12.dmg). You might also want to visit the [Release Notes wiki page](https://github.com/hjuutilainen/munkiadmin/wiki/Release-Notes)

MunkiAdmin requires:

* Mac OS X 10.6 or later
* munki tools installed in default location (/usr/local/munki/)

### Build from source:

Clone, fork or download the source. Open MunkiAdmin.xcodeproj with Xcode and hit 'Run'. If you're making changes to the data model, you need to use mogenerator to keep NSManagedObject subclasses updated. So in short:

* Xcode 4 or later
* OS X SDK (comes with Xcode)
* Optional: [mogenerator + Xmo'd](http://github.com/rentzsch/mogenerator)


# Contact

For any questions, problems or version announcements, please join the MunkiAdmin's google group: [munkiadmin-dev](https://groups.google.com/d/forum/munkiadmin-dev). If you don't want to join the google group, you can always email me directly. My public email address can be found at the [GitHub profile page](https://github.com/hjuutilainen).

Please let me know if you are testing, using or just planning to use MunkiAdmin in your organization. I'd be happy to share my workflow and discuss about possible caveats.


# Thanks to:

* Jonathan Rentzsch for his [mogenerator](http://github.com/rentzsch/mogenerator)
* CocoaDev [MultiPanePreferences](http://www.cocoadev.com/index.pl?MultiPanePreferences)
* Cathy Shive for [NSCell example code](http://katidev.com/blog/2008/02/22/styling-an-nstableview-dttah/)
* MunkiAdmin uses developer icons created by these wonderful people:
    * [Glyphish Pro](http://www.glyphish.com)
    * [Jonatan Castro Fernández](http://www.midtonedesign.com)
    * Jonas Rask Design
    * Matt Ball Design
