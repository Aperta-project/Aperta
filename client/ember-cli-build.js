/* global require, module */
var EmberApp   = require('ember-cli/lib/broccoli/ember-app');
var mergeTrees = require('broccoli-merge-trees');
var Funnel     = require('broccoli-funnel');

module.exports = function(defaults) {
  var app = new EmberApp(defaults, {
    // calculated config will be stored in the final tahi.js file
    storeConfigInMeta: false,

    emberCliFontAwesome: { includeFontAwesomeAssets: false },

    // log markers on application boot
    markers: {
      enabled: true,
      kinds: ['TODO', 'FIXME']
    }
  });

  app.import('bower_components/underscore/underscore-min.js');
  app.import('bower_components/moment/moment.js');

  // Pusher
  app.import(app.bowerDirectory + '/pusher/dist/pusher.js');
  app.import(app.bowerDirectory + '/ember-pusher/ember-pusher.amd.js', {
    exports: {
      'ember-pusher/controller':    ['Controller'],
      'ember-pusher/bindings':      ['Bindings'],
      'ember-pusher/client_events': ['ClientEvents']
    }
  });

  // jQuery UI
  app.import('bower_components/jquery-ui/ui/core.js');
  app.import('bower_components/jquery-ui/ui/widget.js');
  app.import('bower_components/jquery-ui/ui/mouse.js');
  app.import('bower_components/jquery-ui/ui/sortable.js');

  // FileUpload
  // (has jquery.ui.widget.js dependency, imported above with jQuery UI)
  app.import('vendor/jquery.iframe-transport.js');
  app.import('vendor/jquery.fileupload/jquery.fileupload.css');
  app.import('vendor/jquery.fileupload/jquery.fileupload.js');

  // Select 2
  app.import('bower_components/select2/select2.js');
  app.import('bower_components/select2/select2.css');
  var select2Assets = new Funnel('bower_components/select2', {
    srcDir: '/',
    files: ['*.gif', '*.png'],
    destDir: '/assets'
  });

  // Bootstrap
  app.import('bower_components/bootstrap/js/collapse.js');
  app.import('bower_components/bootstrap/js/dropdown.js');
  app.import('bower_components/bootstrap/js/tooltip.js');
  app.import('bower_components/bootstrap-datepicker/css/datepicker3.css');
  app.import('bower_components/bootstrap-datepicker/js/bootstrap-datepicker.js');

  if (app.env !== 'production') {
    app.import('bower_components/sinon/index.js', { type: 'test' });
    app.import('bower_components/ember/ember-template-compiler.js', { type: 'test' });
    app.import('vendor/pusher-test-stub.js', { type: 'test' });
  }

  return mergeTrees([app.toTree(), select2Assets], {overwrite: true});
};
