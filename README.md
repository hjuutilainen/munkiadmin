# What is MunkiAdmin?

MunkiAdmin is a GUI for managing munki repositories. It is written
with Objective-C and uses in-memory Core Data store as a backend.

So what is munki and what are those munki repositories then? Well,
munki is a set of tools that allow administrators to define managed
installs for client machines. Repositories are served from a standard
web server.

For more information, visit [Munki tools homepage](http://code.google.com/p/munki/)

# How to get MunkiAdmin?

### Download a pre-built version:

See the [MunkiAdmin downloads page](https://github.com/hjuutilainen/munkiadmin/downloads) and [Release Notes wiki page](https://github.com/hjuutilainen/munkiadmin/wiki/Release-Notes)

* Mac OS X 10.6 or later
* munki tools installed in default location (/usr/local/munki/)

### Build from source:

Clone, fork or download the source. Open MunkiAdmin.xcodeproj with Xcode and hit 'Run'. If you're making changes to the data model, you need to use mogenerator to keep NSManagedObject subclasses updated. So in short:

* Xcode 4 on Snow Leopard or Lion
* 10.6 or 10.7 SDK
* Optional: [mogenerator + Xmo'd](http://github.com/rentzsch/mogenerator)

# Important:

Code is _not_ considered stable and production ready. If you wan't to run this on a production repo, make sure your backups are current or you have some other methods for going back in time. I'm using git version control on my test repos so I'll always know what was changed.


# Thanks to:

* Jonathan Rentzsch for his [mogenerator](http://github.com/rentzsch/mogenerator)
* CocoaDev [MultiPanePreferences](http://www.cocoadev.com/index.pl?MultiPanePreferences)
* Cathy Shive for [NSCell example code](http://katidev.com/blog/2008/02/22/styling-an-nstableview-dttah/)
* Developer icons from various sources:
	* [Jonas Rask Design](http://jonasraskdesign.com)
	* [Matt Ball](http://www.mattballdesign.com/)
	* [Jonatan Castro Fernández](http://www.midtonedesign.com)
