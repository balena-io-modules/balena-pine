
/*
The MIT License

Copyright (c) 2015 Resin.io, Inc. https://resin.io.

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
 */

/**
 * @module pine
 */
var PinejsClientCore, Promise, ResinPine, request, _,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

_ = require('lodash');

Promise = require('bluebird');

PinejsClientCore = require('pinejs-client/core')(_, Promise);

request = require('resin-request');


/**
 * @class
 * @classdesc A PineJS Client subclass to communicate with Resin.io.
 * @private
 *
 * @description
 * This subclass makes use of the [resin-request](https://github.com/resin-io/resin-request) project.
 */

ResinPine = (function(_super) {
  __extends(ResinPine, _super);

  function ResinPine() {
    return ResinPine.__super__.constructor.apply(this, arguments);
  }


  /**
  	 * @summary Perform a network request to Resin.io.
  	 * @method
  	 * @private
  	 *
  	 * @param {Object} options - request options
  	 * @returns {Promise<*>} response body
  	 *
  	 * @todo Implement caching support.
   */

  ResinPine.prototype._request = function(options) {
    if (options.timeout == null) {
      options.timeout = 30000;
    }
    return request.send(options).get('body');
  };

  return ResinPine;

})(PinejsClientCore);

module.exports = new ResinPine({
  apiPrefix: '/ewa/'
});
