resin-pine
----------

[![npm version](https://badge.fury.io/js/resin-pine.svg)](http://badge.fury.io/js/resin-pine)
[![dependencies](https://david-dm.org/resin-io/resin-pine.png)](https://david-dm.org/resin-io/resin-pine.png)
[![Build Status](https://travis-ci.org/resin-io/resin-pine.svg?branch=master)](https://travis-ci.org/resin-io/resin-pine)
[![Build status](https://ci.appveyor.com/api/projects/status/cwh3jfc7vur5bvmu?svg=true)](https://ci.appveyor.com/project/jviotti/resin-pine)

Resin.io PineJS client.

Role
----

The intention of this module is to provide a ready to use subclass of [pinejs-client-js](https://github.com/resin-io/pinejs-client-js) which uses [resin-request](https://github.com/resin-io/resin-request).

**THIS MODULE IS LOW LEVEL AND IS NOT MEANT TO BE USED BY END USERS DIRECTLY**.

Unless you know what you're doing, use the [Resin SDK](https://github.com/resin-io/resin-sdk) instead.

Installation
------------

Install `resin-pine` by running:

```sh
$ npm install --save resin-pine
```

Documentation
-------------

Head over to [pinejs-client-js](https://github.com/resin-io/pinejs-client-js) for documentation.

Support
-------

If you're having any problem, please [raise an issue](https://github.com/resin-io/resin-pine/issues/new) on GitHub and the Resin.io team will be happy to help.

Tests
-----

Run the test suite by doing:

```sh
$ gulp test
```

Contribute
----------

- Issue Tracker: [github.com/resin-io/resin-pine/issues](https://github.com/resin-io/resin-pine/issues)
- Source Code: [github.com/resin-io/resin-pine](https://github.com/resin-io/resin-pine)

Before submitting a PR, please make sure that you include tests, and that [coffeelint](http://www.coffeelint.org/) runs without any warning:

```sh
$ gulp lint
```

License
-------

The project is licensed under the Apache 2.0 license.
