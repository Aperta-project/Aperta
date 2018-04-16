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

/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var Funnel   = require('broccoli-funnel');

module.exports = function(defaults) {
  var args = {
    app: {
      css: {
        app: "/assets/css/tahi.css"
      },
      js: "/assets/js/tahi.js"
    },

    vendor: {
      css: "/assets/css/vendor.css",
      js: "/assets/js/vendor.js"
    },
    hinting: false,
    storeConfigInMeta: false,
    'ember-font-awesome': {
      includeFontAwesomeAssets: false,
      useScss: true,
      includeFontFiles: false,
    },
    'ember-cli-qunit': {
      useLintTree: false
    },
    sourcemaps: {
      enabled: true,
      extensions: ['js']
    },
    'ember-cli-babel': {
      includePolyfill: true
    },
    codemirror: {
      modes: ['xml'],
      themes: ['eclipse']
    },
    minifyJS: {
      enabled: EmberApp.env() === 'production'
    },
    fingerprint: {
      exclude: ['skins', 'plugins']
    }
  };

  var app = new EmberApp(defaults, args);

  app.import(app.bowerDirectory + '/underscore/underscore.js');

  // jQuery UI
  app.import(app.bowerDirectory + '/jquery-ui/ui/core.js');
  app.import(app.bowerDirectory + '/jquery-ui/ui/widget.js');
  app.import(app.bowerDirectory + '/jquery-ui/ui/mouse.js');
  app.import(app.bowerDirectory + '/jquery-ui/ui/sortable.js');

  // FileUpload
  // (has jquery.ui.widget.js dependency, imported above with jQuery UI)
  app.import('vendor/jquery.iframe-transport.js');
  app.import('vendor/jquery.fileupload/jquery.fileupload.css');
  app.import('vendor/jquery.fileupload/jquery.fileupload.js');

  // Select 2
  app.import(app.bowerDirectory + '/select2/select2.js');
  app.import(app.bowerDirectory + '/select2/select2.css');
  var select2Assets = new Funnel(app.bowerDirectory + '/select2', {
    srcDir: '/',
    include: ['*.gif', '*.png'],
    destDir: '/assets'
  });

  // JsDiff
  app.import(app.bowerDirectory + '/jsdiff/diff.js');

  // lscache
  app.import(app.bowerDirectory + '/lscache/lscache.js');

  // Bootstrap
  app.import(app.bowerDirectory + '/bootstrap/js/collapse.js');
  app.import(app.bowerDirectory + '/bootstrap/js/dropdown.js');
  app.import(app.bowerDirectory + '/bootstrap/js/tooltip.js');
  app.import(app.bowerDirectory + '/bootstrap/js/tab.js');
  app.import(app.bowerDirectory + '/bootstrap-datepicker/css/datepicker3.css');
  app.import(app.bowerDirectory + '/bootstrap-datepicker/js/bootstrap-datepicker.js');

  // jQuery timepicker
  app.import(app.bowerDirectory + '/jt.timepicker/jquery.timepicker.min.js');
  app.import(app.bowerDirectory + '/jt.timepicker/jquery.timepicker.css');

  // At.js
  app.import(app.bowerDirectory + '/At.js/dist/css/jquery.atwho.css');

  if (app.env !== 'production') {
    app.import('vendor/pusher-test-stub.js', { type: 'test' });
  }

  return app.toTree([select2Assets]);
};
