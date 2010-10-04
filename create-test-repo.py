#!/usr/bin/env python
# encoding: utf-8
"""
create-test-repo.py

Created by Hannes Juutilainen on 2010-10-04.
"""

import sys
import getopt
import os
import subprocess
import plistlib
import uuid
import random
import string

numPackages = 100
numCatalogs = 10
numManifests = 10

words = open('/usr/share/dict/words').readlines()
appNames = []

output = ""

packageTitles = []
catalogTitles = []
manifestTitles = []

help_message = '''
This script creates a munki repository with dummy content.
	[-o|--output]		A directory for the repo
	[-p|--packages]		Number of package objects to create (100 by default)
	[-c|--catalogs]		Number of catalog objects to create (10 by default)
	[-m|--manifests]	Number of manifest objects to create (10 by default)
'''

class Usage(Exception):
	def __init__(self, msg):
		self.msg = msg

def newPackage(title):
	"""Create a dummy package with random title"""
	# Create random version
	versionMajor = random.randint(1, 9)
	versionMinor = random.randint(0, 9)
	versionMaintenance = random.randint(0, 9)
	versionBuild = random.randint(100, 999)
	version = "%i.%i.%i.%i" % (versionMajor, versionMinor, versionMaintenance, versionBuild)
	#title = str(uuid.uuid4())
	#title = words[random.randrange(0, len(words))][:-1]
	#title = random.choice(words).strip()
	titleWithVersion = '-'.join([title, version])
	global packageTitles
	packageTitles.append(title)
	filename = ".".join([titleWithVersion, "plist"])
	pkginfoFilePath = os.path.join(pkgsinfoPath, filename)
	# Create an empty .pkg.dmg dummy file
	pkgFilename = ".".join([titleWithVersion, "pkg.dmg"])
	pkgFilePath = os.path.join(pkgsPath, pkgFilename)
	open(pkgFilePath, 'w').close()
	# Add random catalogs
	catalogs = []
	for j in range(0, random.randint(1, numCatalogs)):
		catalogs.append(random.choice(catalogTitles))
	# Random Description
	descrWords = []
	for i in range(0, random.randint(1, 50)):
		descrWords.append(random.choice(words).strip())
	description = ' '.join(descrWords)
	# Compile the pkginfo file contents
	pl = {	'name':						title,
			'version':					version,
			'display_name':				title,
			'minimum_os_vers':			'10.5.0',
			'description':				description,
			'catalogs':					catalogs,
			'installer_item_location':	pkgFilename,
			'uninstallable':			True,
			'uninstall_method':			'removepackages',
			'installed_size':			random.randint(100, 1000000),
			'installer_item_size':		random.randint(100, 1000000),
			}
	plistlib.writePlist(pl, pkginfoFilePath)
	pass


def newManifest():
	"""Create a new manifest with random title"""
	global manifestTitles
	#title = words[random.randrange(0, len(words))][:-1]
	title = random.choice(words).strip()
	manifestTitles.append(title)
	manifestFilePath = os.path.join(manifestsPath, title)
	# Add random catalogs
	catalogs = []
	for j in range(0, random.randint(1, numCatalogs)):
		catalogs.append(random.choice(catalogTitles))
	# Add random managed installs
	managedInstalls = []
	for j in range(0, random.randint(1, numPackages)):
		managedInstalls.append(random.choice(packageTitles))
	# Add random managed uninstalls
	managedUninstalls = []
	for j in range(0, random.randint(1, numPackages)):
		managedUninstalls.append(random.choice(packageTitles))
	pl = {	'catalogs':				catalogs,
			'managed_installs':		managedInstalls,
			'managed_uninstalls':	managedUninstalls,
			}
	plistlib.writePlist(pl, manifestFilePath)
	pass

def newCatalog():
	"""Create a new catalog with random title"""
	global catalogTitles
	#title = words[random.randrange(0, len(words))][:-1]
	title = random.choice(words).strip()
	catalogTitles.append(title)
	pass

def createBaseLayout():
	"""Create default repo directories"""
	if not os.path.exists(catalogsPath):
		os.makedirs(catalogsPath)
	if not os.path.exists(pkgsinfoPath):
		os.makedirs(pkgsinfoPath)
	if not os.path.exists(pkgsPath):
		os.makedirs(pkgsPath)
	if not os.path.exists(manifestsPath):
		os.makedirs(manifestsPath)
	pass

def main(argv=None):
	if argv is None:
		argv = sys.argv
	try:
		try:
			opts, args = getopt.getopt(argv[1:], "c:p:m:ho:v", ["catalogs=", "packages=", "manifests=", "help", "output="])
		except getopt.error, msg:
			raise Usage(msg)
	
		# option processing
		for option, value in opts:
			if option == "-v":
				verbose = True
			if option in ("-h", "--help"):
				raise Usage(help_message)
			if option in ("-o", "--output"):
				global output
				output = value
				global catalogsPath
				catalogsPath = os.path.join(output, "catalogs")
				global pkgsPath
				pkgsPath = os.path.join(output, "pkgs")
				global pkgsinfoPath
				pkgsinfoPath = os.path.join(output, "pkgsinfo")
				global manifestsPath
				manifestsPath = os.path.join(output, "manifests")
			if option in ("-c", "--catalogs"):
				global numCatalogs
				numCatalogs = int(value)
			if option in ("-p", "--packages"):
				global numPackages
				numPackages = int(value)
			if option in ("-m", "--manifests"):
				global numManifests
				numManifests = int(value)
		
		if output == "":
			raise Usage(help_message)
		
		print "Creating a repo with properties:"
		print "--->  %s" % output
		print "--->  %i packages" % numPackages
		print "--->  %i catalogs" % numCatalogs
		print "--->  %i manifests" % numManifests
		createBaseLayout()
		
		for i in range(0, numCatalogs):
			newCatalog()
		
		previousPackage = random.choice(words).strip()
		for i in range(0, numPackages):
			# Maybe this a version for previous...?
			isVersion = random.choice([True, False])
			if isVersion:
				newPackage(previousPackage)
			else:
				newTitle = random.choice(words).strip()
				newPackage(newTitle)
				previousPackage = newTitle
		
		for i in range(0, numManifests):
			newManifest()
		
	except Usage, err:
		print >> sys.stderr, sys.argv[0].split("/")[-1] + ": " + str(err.msg)
		print >> sys.stderr, "\t for help use --help"
		return 2


if __name__ == "__main__":
	sys.exit(main())
