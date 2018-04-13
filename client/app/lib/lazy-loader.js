/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

/* global $ */
import Ember from 'ember';

var Promise = Ember.RSVP.Promise;

var _loadedScripts = {};

// This version injects a script instead of using global.eval
// which eases debugging (e.g., stacktraces make sense)
var injectScript = function(src, cb) {
  Ember.Logger.info('Loading script %s', src);
  if (_loadedScripts[src]) {
    return cb();
  }
  var headEl = document.head || document.getElementsByTagName('head')[0];
  var scriptEl = window.document.createElement('script');
  scriptEl.type = 'text\/javascript';
  scriptEl.src = src;
  scriptEl.onload = function() {
    _loadedScripts[src] = true;
    cb();
  };
  scriptEl.onerror = function (error) {
    var err = new URIError('The script ' + error.target.src + ' is not accessible.');
    console.error('Could not load', src);
    cb(err);
  };
  headEl.appendChild(scriptEl);
};

export default {
  loadScripts: function(urls) {
    // if assets are included in the bundle, then just initialize the platform
    return new Promise(function(resolve, reject) {
      var i = 0;
      function loadScript(err) {
        if (err) {
          reject(err);
        } else if (i >= urls.length) {
          resolve();
        } else {
          injectScript(urls[i++], loadScript);
        }
      }
      // start the loading sequence
      loadScript();
    });
  },
  loadCSS: function(url) {
    if (!_loadedScripts[url]) {
      $('<link/>', {
        rel: 'stylesheet',
        type: 'text/css',
        href: url
      }).appendTo('head');
      _loadedScripts[url] = true;
    }
  },
};
