/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var mergeTrees = require('broccoli-merge-trees');
var pickFiles = require('broccoli-static-compiler');

var app = new EmberApp({
  storeConfigInMeta: false,
  emberCliFontAwesome: { includeFontAwesomeAssets: false },
  'ember-cli-bootstrap-sassy': {
    'glyphicons': false
  },
  sassOptions: {
    sourceMap: false,
    includePaths: [
      'bower_components/bourbon/app/assets/stylesheets'
    ]
  }
});

app.import('bower_components/underscore/underscore-min.js');
app.import('bower_components/moment/moment.js');

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

// Bootstrap
app.import('bower_components/bootstrap-sass/assets/javascripts/bootstrap/collapse.js');
app.import('bower_components/bootstrap-sass/assets/javascripts/bootstrap/dropdown.js');
app.import('bower_components/bootstrap-sass/assets/javascripts/bootstrap/tooltip.js');
app.import('bower_components/bootstrap-datepicker/dist/css/bootstrap-datepicker3.css');
app.import('bower_components/bootstrap-datepicker/dist/js/bootstrap-datepicker.js');

// Select 2
app.import('bower_components/select2/select2.js');
app.import('bower_components/select2/select2.css');
var select2Assets = pickFiles('bower_components/select2', {
  srcDir: '/',
  files: ['*.gif', '*.png'],
  destDir: 'assets'
});

var fontAwesomeAssets = pickFiles('bower_components/font-awesome', {
  srcDir: '/',
  files: ['css/*', 'fonts/*'],
  destDir: ''
});

// Ember-cli styles that live in Rails' /app/engines/
var addons = ["tahi_standard_tasks", "plos_authors", "tahi_upload_manuscript"];

// Engine addons are expected to have css at /client/app/styles/
var addonStyles = addons.map(function(engineName) {
  return pickFiles('../engines/' + engineName + '/client/app/styles', {
    srcDir: '/',
    files: ['*'],
    destDir: 'assets'
  });
});

// app.import("bower_components/font-awesome/css/font-awesome.css");
// app.import("bower_components/font-awesome/fonts/fontawesome-webfont.eot", { destDir: "fonts" });
// app.import("bower_components/font-awesome/fonts/fontawesome-webfont.svg", { destDir: "fonts" });
// app.import("bower_components/font-awesome/fonts/fontawesome-webfont.ttf", { destDir: "fonts" });
// app.import("bower_components/font-awesome/fonts/fontawesome-webfont.woff", { destDir: "fonts" });
// app.import("bower_components/font-awesome/fonts/fontawesome-webfont.woff2", { destDir: "fonts" });
// app.import("bower_components/font-awesome/fonts/FontAwesome.otf", { destDir: "fonts" });

if (app.env !== 'production') {
  app.import('bower_components/sinon/index.js', { type: 'test' });
  app.import('bower_components/ember/ember-template-compiler.js', { type: 'test' });
  app.import('vendor/pusher-test-stub.js', { type: 'test' });
}

module.exports = mergeTrees([app.toTree(), select2Assets, fontAwesomeAssets].concat(addonStyles), {overwrite: true});
