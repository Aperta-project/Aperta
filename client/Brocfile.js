/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');
var mergeTrees = require('broccoli-merge-trees');
var pickFiles = require('broccoli-static-compiler');

var app = new EmberApp({
  storeConfigInMeta: false,
  emberCliFontAwesome: { includeFontAwesomeAssets: false },
  'ember-cli-bootstrap-sassy': {
    'glyphicons': false
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

// Select 2
app.import('bower_components/select2/select2.js');
app.import('bower_components/select2/select2.css');
var select2Assets = pickFiles('bower_components/select2', {
  srcDir: '/',
  files: ['*.gif', '*.png'],
  destDir: 'assets'
});

var tahiStandardTaskStyles = pickFiles('../engines/tahi_standard_tasks/client/app/styles', {
  srcDir: '/tahi_standard_tasks',
  files: ['*'],
  destDir: 'assets'
});

// Bootstrap
app.import('bower_components/bootstrap/js/collapse.js');
app.import('bower_components/bootstrap/js/dropdown.js');
app.import('bower_components/bootstrap/js/tooltip.js');
app.import('bower_components/bootstrap-datepicker/css/datepicker3.css');
app.import('bower_components/bootstrap-datepicker/js/bootstrap-datepicker.js');

if (app.env === 'production') {
  app.import('bower_components/event-source-polyfill/eventsource.js');
} else {
  app.import('bower_components/sinon/index.js');
  app.import('bower_components/ember/ember-template-compiler.js');
}

module.exports = mergeTrees([app.toTree(), select2Assets, tahiStandardTaskStyles], {overwrite: true});
