/* global require, module */
var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var Funnel   = require('broccoli-funnel');

module.exports = function(defaults) {
  var args = {
    hinting: false,
    storeConfigInMeta: false,
    emberCliFontAwesome: { includeFontAwesomeAssets: true },
    'ember-cli-qunit': {
      useLintTree: false
    },
    sourcemaps: {
      enabled: true,
      extensions: ['js']
    },
    babel: {
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
      exclude: ['skins/lightgray/fonts', 'skins/lightgray', 'plugins/codesample/css']
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

  // TinyMCE
  app.import(app.bowerDirectory + '/tinymce/plugins/codesample/css/prism.css');

  app.import(app.bowerDirectory + '/tinymce/tinymce.min.js');
  app.import(app.bowerDirectory + '/tinymce/themes/modern/theme.min.js');
  app.import(app.bowerDirectory + '/tinymce/plugins/code/plugin.min.js');
  app.import(app.bowerDirectory + '/tinymce/plugins/codesample/plugin.min.js');
  app.import(app.bowerDirectory + '/tinymce/plugins/paste/plugin.min.js');
  app.import(app.bowerDirectory + '/tinymce/plugins/table/plugin.min.js');
  app.import(app.bowerDirectory + '/tinymce/plugins/link/plugin.min.js');
  app.import(app.bowerDirectory + '/tinymce/plugins/autoresize/plugin.min.js');

  var tinymceFonts = new Funnel(app.bowerDirectory + '/tinymce/skins/lightgray/fonts', {
    srcDir: '/',
    include: ['*.woff', '*.ttf'],
    destDir: '/assets/skins/lightgray/fonts'
  });

  var tinymceCSS = new Funnel(app.bowerDirectory + '/tinymce/skins/lightgray/', {
    srcDir: '/',
    include: ['*.css'],
    destDir: '/assets/skins/lightgray'
  });

  var prism = new Funnel(app.bowerDirectory + '/tinymce/plugins/codesample/css', {
    srcDir: '/',
    include: ['*.css'],
    destDir: '/assets/plugins/codesample/css'
  });

  if (app.env !== 'production') {
    app.import('vendor/pusher-test-stub.js', { type: 'test' });
  }

  return app.toTree([select2Assets, tinymceFonts, tinymceCSS, prism]);
};
