/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var Funnel   = require('broccoli-funnel');

module.exports = function(defaults) {
  var args = {
    hinting: false,
    storeConfigInMeta: false,
    emberCliFontAwesome: { includeFontAwesomeAssets: false },
    'ember-cli-qunit': {
      useLintTree: false
    },
    sourcemaps: {
      enabled: true,
      extensions: ['js']
    },
    babel: {
      includePolyfill: true
    }
  };

  var app = new EmberApp(defaults, args);

  app.import(app.bowerDirectory + '/underscore/underscore.js');
  app.import(app.bowerDirectory + '/moment/moment.js');

  // Pusher
  app.import(app.bowerDirectory + '/pusher/dist/web/pusher.js');
  app.import(app.bowerDirectory + '/ember-pusher/ember-pusher.amd.js', {
    exports: {
      'ember-pusher/controller':    ['Controller'],
      'ember-pusher/bindings':      ['Bindings'],
      'ember-pusher/client_events': ['ClientEvents']
    }
  });

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
  app.import(app.bowerDirectory + '/bootstrap/js/tooltip.js');
  app.import(app.bowerDirectory + '/bootstrap-datepicker/css/datepicker3.css');
  app.import(app.bowerDirectory + '/bootstrap-datepicker/js/bootstrap-datepicker.js');

  // At.js
  app.import(app.bowerDirectory + '/At.js/dist/css/jquery.atwho.css');

  if (app.env !== 'production') {
    app.import(app.bowerDirectory + '/sinon/index.js', { type: 'test' });
    app.import(app.bowerDirectory + '/ember/ember-template-compiler.js', { type: 'test' });
    app.import('vendor/pusher-test-stub.js', { type: 'test' });
  }

  return app.toTree(select2Assets);
};
