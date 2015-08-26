/* global require, module */
var EmberApp   = require('ember-cli/lib/broccoli/ember-app');
var mergeTrees = require('broccoli-merge-trees');
var Funnel     = require('broccoli-funnel');

module.exports = function(defaults) {
  var app = new EmberApp(defaults, {
    // calculated config will be stored in the final tahi.js file
    storeConfigInMeta: false,
    emberCliFontAwesome: { includeFontAwesomeAssets: false },
    sourcemaps: {
      enabled: true,
      extensions: ['js']
    }
  });

  var b = app.bowerDirectory + '/';
  var v = 'vendor/';

  app.import(b + 'underscore/underscore-min.js');
  app.import(b + 'moment/moment.js');

  // Pusher
  app.import(b + 'pusher/dist/pusher.js');
  app.import(b + 'ember-pusher/ember-pusher.amd.js', {
    exports: {
      'ember-pusher/controller':    ['Controller'],
      'ember-pusher/bindings':      ['Bindings'],
      'ember-pusher/client_events': ['ClientEvents']
    }
  });

  // jQuery UI
  app.import(b + 'jquery-ui/ui/core.js');
  app.import(b + 'jquery-ui/ui/widget.js');
  app.import(b + 'jquery-ui/ui/mouse.js');
  app.import(b + 'jquery-ui/ui/sortable.js');

  // FileUpload
  // (has jquery.ui.widget.js dependency, imported above with jQuery UI)
  app.import(v + 'jquery.iframe-transport.js');
  app.import(v + 'jquery.fileupload/jquery.fileupload.css');
  app.import(v + 'jquery.fileupload/jquery.fileupload.js');

  // Select 2
  app.import(b + 'select2/select2.js');
  app.import(b + 'select2/select2.css');
  var select2Assets = new Funnel(b + 'select2', {
    srcDir: '/',
    files: ['*.gif', '*.png'],
    destDir: '/assets'
  });

  // JsDiff
  app.import('bower_components/jsdiff/diff.js');

  // Bootstrap
  app.import(b + 'bootstrap/js/collapse.js');
  app.import(b + 'bootstrap/js/dropdown.js');
  app.import(b + 'bootstrap/js/tooltip.js');
  app.import(b + 'bootstrap-datepicker/css/datepicker3.css');
  app.import(b + 'bootstrap-datepicker/js/bootstrap-datepicker.js');

  if (app.env !== 'production') {
    app.import(b + 'sinon/index.js', { type: 'test' });
    app.import(b + 'ember/ember-template-compiler.js', { type: 'test' });
    app.import(v + 'pusher-test-stub.js', { type: 'test' });
  }

  return mergeTrees([app.toTree(), select2Assets], {overwrite: true});
};
