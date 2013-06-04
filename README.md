rOCCI-core - A Ruby OCCI Framework
=================================

[![Build Status](https://secure.travis-ci.org/gwdg/rOCCI-core.png)](http://travis-ci.org/gwdg/rOCCI-core)
[![Dependency Status](https://gemnasium.com/gwdg/rOCCI-core.png)](https://gemnasium.com/gwdg/rOCCI-core)
[![Gem Version](https://fury-badge.herokuapp.com/rb/occi-core.png)](https://badge.fury.io/rb/occi-core)
[![Code Climate](https://codeclimate.com/github/gwdg/rOCCI-core.png)](https://codeclimate.com/github/gwdg/rOCCI-core)

Requirements
------------

Ruby
* at least version 1.8.7 is required

The following setup is recommended

* usage of the Ruby Version Manager
* Ruby 1.9.3
* RubyGems installed

The following libraries / packages may be required to use rOCCI

* libxslt-dev
* libxml2-dev
* **only if using Ruby 1.8.7:** libonig-dev (Linux) or oniguruma (Mac)

Installation
------------

**[Mac OS X has some special requirements for the installation. Detailed information can be found in
doc/macosx.md.](doc/macosx.md)**

To install the most recent stable version

    gem install occi-core

To install the most recent beta version

    gem install occi-core --pre

### Installation from source

To use rOCCI from source it is very much recommended to use RVM. [Install RVM](https://rvm.io/rvm/install/) with

    curl -L https://get.rvm.io | bash -s stable --ruby

#### Ruby

To build and install the bleeding edge version from master

    git clone git://github.com/gwdg/rOCCI-core.git
    cd rOCCI-core
    rvm install ruby-1.9.3
    rvm --create --ruby-version use 1.9.3@rOCCI-core
    bundle install
    rake test

Usage
-----
#### Logging

The OCCI gem includes its own logging mechanism using a message queue. By default, no one is listening to that queue.
A new OCCI Logger can be initialized by specifying the log destination (either a filename or an IO object like
STDOUT) and the log level.

    Occi::Log.new(STDOUT,Occi::Log::INFO)

You can create multiple Loggers to receive the log output.

You can always, even if there is no logger defined, log output using the class methods of OCCI::Log e.g.

    Occi::Log.info("Test message")

#### Registering categories in the OCCI Model

Before the parser may be used, the available categories have to be registered in the OCCI Model.

For categories already specified by the OCCI WG a method exists in the OCCI Model class to register them:

    model = Occi::Model.new
    model.register_infrastructure

Further categories can either be registered from files which include OCCI collections in JSON formator or from parsed
 JSON objects (e.g. from the query interface of an OCCI service endpoint).

#### Parsing OCCI messages

The OCCI gem includes a Parser to easily parse OCCI messages. With a given media type (e.g. json,
xml or plain text) the parser analyses the content of the message body and, if supplied,
the message header. As the text/plain and text/occi media type do not clearly distinguish between a message with a
category and a message with an entity which has a kind, it has to be specified if the message contains a category (e
.g. for user defined mixins)

OCCI messages can be parsed to an OCCI collection for example like

    media_type = 'text/plain'
    body = %Q|Category: compute; scheme="http://schemas.ogf.org/occi/infrastructure#"; class="kind"|
    collection=Occi::Parser.parse(media_type, body)

#### Parsing OVF / OVA files

Parsing of OVF/OVA files is partly supported and will be improved in future versions.

The example in [DMTF DSP 2021](http://www.dmtf.org/sites/default/files/standards/documents/DSP2021_1.0.0.tar) is
bundled with rOCCI and can be parsed to an OCCI collection with

    require 'open-uri'
    ova=open 'https://raw.github.com/gwdg/rOCCI/master/spec/occi/test.ova'
    collection=Occi::Parser.ova(ova.read)

Currently only the following entries of OVF files are parsed

* File in References
* Disk in the DiskSection
* Network in the NetworkSection
* In the VirutalSystemSection:
** Info
** in the VirtualHardwareSection the items regarding
*** Processor
*** Memory
*** Ethernet Adapter
*** Parallel port

### Using the OCCI model

The occi-core gem includes all OCCI Core classes necessary to handly arbitrary OCCI objects.

Changelog
---------

### Version 3.1
* added basic OS Keystone support
* added support for PKCS12 credentials for X.509 authN
* updated templates for plain output formatting
* minor client API changes
* several bugfixes

### Version 3.0

* many bugfixes
* rewrote Core classes to use metaprogramming techniques
* added VCR cassettes for reliable testing against prerecorded server responses
* several updates to the OCCI Client
* started work on an OCCI Client using AMQP as transport protocol
* added support for keystone authentication to be used with the OpenStack OCCI server
* updated dependencies
* updated rspec tests
* started work on cucumber features

### Version 2.5

* improved OCCI Client
* improved documentation
* several bugfixes

### Version 2.4

* Changed OCCI attribute properties from lowercase to first letter uppercase (e.g. type -> Type, default -> Default, ...)

### Version 2.3

* OCCI objects are now initialized with a list of attributes instead of a hash. Thus it is easier to check which
attributes are expected by a class and helps prevent errors.
* Parsing of a subset of the OVF specification is supported. Further parts of the specification will be covered in
future versions of rOCCI.

### Version 2.2

* OCCI Client added. The client simplifies the execution of OCCI commands and provides shortcuts for often used steps.

### Version 2.1

* Several improvements to the gem structure and code documentation. First rSpec test were added. Readme has been extended to include instructions how the gem can be used.

### Version 2.0

* Starting with version 2.0 Florian Feldhaus and Piotr Kasprzak took over the development of the OCCI gem. The codebase was taken from the rOCCI framework and improved to be bundled as a standalone gem.

### Version 1.X

* Version 1.X of the OCCI gem has been developed by retr0h and served as a simple way to access the first OpenNebula OCCI implementation.

Development
-----------

Checkout latest version from git:

    git clone git://github.com/gwdg/rOCCI-core.git

Change to rOCCI-core folder

    cd rOCCI-core

Install dependencies

    bundle install

### Code Documentation

[Code Documentation for rOCCI by YARD](http://rubydoc.info/github/gwdg/rOCCI-core/)

### Continuous integration

[Continuous integration for rOCCI by Travis-CI](http://travis-ci.org/gwdg/rOCCI-core/)

### Contribute

1. Fork it.
2. Create a branch (git checkout -b my_markup)
3. Commit your changes (git commit -am "My changes")
4. Push to the branch (git push origin my_markup)
5. Create an Issue with a link to your branch
