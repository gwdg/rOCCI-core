rOCCI-core - A Ruby OCCI Framework
=================================

[![Build Status](https://secure.travis-ci.org/EGI-FCTF/rOCCI-core.png)](http://travis-ci.org/EGI-FCTF/rOCCI-core)
[![Dependency Status](https://gemnasium.com/EGI-FCTF/rOCCI-core.png)](https://gemnasium.com/EGI-FCTF/rOCCI-core)
[![Gem Version](https://fury-badge.herokuapp.com/rb/occi-core.png)](https://badge.fury.io/rb/occi-core)
[![Code Climate](https://codeclimate.com/github/EGI-FCTF/rOCCI-core.png)](https://codeclimate.com/github/EGI-FCTF/rOCCI-core)

Requirements
------------

### Ruby
* Ruby 1.9.3 is required
* RubyGems have to be installed

### Examples
#### For distros based on Debian:
~~~
apt-get install ruby rubygems ruby-dev
~~~
~~~
ruby -v
~~~

**Unless you have Ruby >= 1.9.3, please, go to [rOCCI-core#RVM](#rvm) and install RVM with a newer Ruby version.**

#### For distros based on RHEL:
~~~
yum install ruby-devel openssl-devel gcc gcc-c++ ruby rubygems
~~~
~~~
ruby -v
~~~

**Unless you have Ruby >= 1.9.3, please, go to [rOCCI-core#RVM](#rvm) and install RVM with a newer Ruby version.**

Installation
------------

### From RubyGems.org

To install the most recent stable version

    gem install occi-core

To install the most recent beta version

    gem install occi-core --pre

### From source (dev)

**Installation from source should never be your first choice! Especially, if you are not familiar with RVM, Bundler, Rake and other dev tools for Ruby!**

**However, if you wish to contribute to our project, this is the right way to start.**

To build and install the bleeding edge version from master

    git clone git://github.com/EGI-FCTF/rOCCI-core.git
    cd rOCCI-core
    gem install bundler
    bundle install
    bundle exec rake spec
    rake install

### RVM

**Notice:** Follow the RVM installation guide linked below, we recommend using the default 'Single-User installation'.

**Warning:** NEVER install RVM as root! If you choose the 'Multi-User installation', use a different user account with sudo access instead!

* [Installing RVM](https://rvm.io/rvm/install#explained)
* Install Ruby

~~~
rvm requirements
rvm install 1.9.3
rvm use 1.9.3 --default
~~~
~~~
ruby -v
~~~

Usage
-----
Detailed documentation is available in our [Wiki](https://github.com/EGI-FCTF/rOCCI-core/wiki).

Changelog
---------

### Version 4.3
* Internal updates and bug fixes
* Updated JSON rendering
* Updated dependencies

### Version 4.2
* Internal changes and bug fixes
* Extended test coverage
* Added custom exceptions and error classes
* Improved text/plain and text/occi rendering

### Version 4.1
* Dropped support for Rubies 1.8.x
* Updated dependencies

### Version 4.0
* introduced compatibility mode (for OCCI-OS, on by default)
* introduced new attribute handling for resources
* completely rewrote OCCI parser
* improved action and mixin handling
* aligned with latest draft of OCCI Core and OCCI JSON specification
* split the code into rOCCI-core, rOCCI-api and rOCCI-cli
* internal changes, refactoring and some bugfixes

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

    git clone git://github.com/EGI-FCTF/rOCCI-core.git

Change to rOCCI-core folder

    cd rOCCI-core

Install dependencies

    bundle install

### Code Documentation

[Code Documentation for rOCCI by YARD](http://rubydoc.info/github/EGI-FCTF/rOCCI-core/)

### Continuous integration

[Continuous integration for rOCCI by Travis-CI](http://travis-ci.org/EGI-FCTF/rOCCI-core/)

### Contribute

1. Fork it.
2. Create a branch (git checkout -b my_markup)
3. Commit your changes (git commit -am "My changes")
4. Push to the branch (git push origin my_markup)
5. Create an Issue with a link to your branch
