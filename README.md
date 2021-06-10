# What is MunkiAdmin?

MunkiAdmin is a macOS app for managing munki repositories. It is a native app written with Objective-C and uses in-memory Core Data store as a backend.

So what is munki and what are those munki repositories then? Well, munki is a set of tools that allow administrators to define managed installs for client machines. Repositories are served from a standard web server.

For more information, visit [Munki tools homepage](https://github.com/munki/munki)


# Important:

Code _is_ considered stable and it shouldn't have any major issues. However, MunkiAdmin is not feature-complete so be prepared to see bugs. If you decide to run this on a production repo, make sure your backups are current or you have some other methods for going back in time. I'm using git version control on my munki repositories so I'll always know what was changed.

You can continue to use your favorite text editor or other tools to edit pkginfo files and manifests. MunkiAdmin is designed to complement your current workflow and it doesn't require any configuration or changes to your munki repository.


# How to get MunkiAdmin?

### Download a pre-built version:

Latest version can be downloaded from the [Releases page](https://github.com/hjuutilainen/munkiadmin/releases/).

MunkiAdmin requires:

* macOS 10.13 or later
* [Munki](https://github.com/munki/munki) components installed (any recent version)

### Build from source:

Clone, fork or download the source. Open ```MunkiAdmin.xcworkspace``` with Xcode and hit 'Run'. If you're making changes to the data model, you need to use mogenerator to keep NSManagedObject subclasses updated. So in short:

* Xcode
* Command Line Developer Tools
* Optional: [mogenerator](http://github.com/rentzsch/mogenerator)


# Contact

For any questions, problems or version announcements, please join the #munkiadmin channel in [MacAdmins Slack](https://macadmins.slack.com). If you don't want to join Slack, you can always email me directly. My public email address can be found at the [GitHub profile page](https://github.com/hjuutilainen).

Please let me know if you are testing, using or just planning to use MunkiAdmin in your organization. I'd be happy to share my workflow and discuss about possible caveats.


# Thanks to:

* Jonathan Rentzsch for his [mogenerator](http://github.com/rentzsch/mogenerator)
* CocoaDev [MultiPanePreferences](http://www.cocoadev.com/index.pl?MultiPanePreferences)
* Cathy Shive for [NSCell example code](http://katidev.com/blog/2008/02/22/styling-an-nstableview-dttah/)
* MunkiAdmin uses developer icons created by these wonderful people:
    * [IKONS by Piotr Kwiatkowski](http://www.ikons.piotrkwiatkowski.co.uk)
    * [Glyphish Pro](http://www.glyphish.com)
    * [Jonatan Castro Fernández](http://www.midtonedesign.com)
    * Jonas Rask Design
    * Matt Ball Design
    * Mika Viikki


# License

MunkiAdmin is licensed under [the MIT License](https://github.com/hjuutilainen/munkiadmin/blob/master/LICENSE)


# Donations

There's no need to donate, the app is free to use and I'm just happy it's useful to other admins. If you absolutely want to support the development of these tools, you should first go and see a Disney movie of your choice (because Munki is an open source project from [Walt Disney Animation Studios](https://www.disneyanimation.com/open-source/) and MunkiAdmin simply wouldn't exist without it). After that, if you're still up for it, you can [buy me a coffee](https://www.buymeacoffee.com/hjuutilainen).
