/* global require, module */

var EmberApp = require('ember-cli/lib/broccoli/ember-app');

var app = new EmberApp({
  storeConfigInMeta: false,
  emberCliFontAwesome: { includeFontAwesomeAssets: false }
});

// Use `app.import` to add additional libraries to the generated
// output files.
//
// If you need to use different assets in different
// environments, specify an object as the first parameter. That
// object's keys should be the environment name and the values
// should be the asset to use in that environment.
//
// If the library that you are including contains AMD or ES6
// modules that you would like to import into your application
// please specify an object with the list of modules as keys
// along with the exports of each module as its value.

app.import('bower_components/spin.js/spin.js');
app.import('bower_components/chosen-bower/chosen.jquery.js');
app.import('bower_components/jquery-timeago/jquery.timeago.js');
app.import('bower_components/underscore/underscore-min.js');
app.import('bower_components/moment/moment.js');
app.import('vendor/bootstrap-tooltip/index.js');

// Datepicker
app.import('bower_components/bootstrap-datepicker/css/datepicker3.css');
app.import('bower_components/bootstrap-datepicker/js/bootstrap-datepicker.js');

// FileUpload
app.import('vendor/jquery.ui.widget.js');
app.import('vendor/jquery.iframe-transport.js');
app.import('vendor/jquery.fileupload/jquery.fileupload.css');
app.import('vendor/jquery.fileupload/jquery.fileupload.js');

app.import('bower_components/jquery-ui/ui/core.js');
app.import('bower_components/jquery-ui/ui/mouse.js');
app.import('bower_components/jquery-ui/ui/widget.js');
app.import('bower_components/jquery-ui/ui/sortable.js');

// Select 2
app.import('bower_components/select2/select2.js');

// bootstrap
app.import('bower_components/bootstrap/dist/js/bootstrap.js');
app.import('bower_components/bootstrap/dist/css/bootstrap.min.css');
app.import('bower_components/bootstrap/dist/css/bootstrap-theme.min.css');
app.import('bower_components/bootstrap/dist/fonts/glyphicons-halflings-regular.eot');
app.import('bower_components/bootstrap/dist/fonts/glyphicons-halflings-regular.svg');
app.import('bower_components/bootstrap/dist/fonts/glyphicons-halflings-regular.ttf');
app.import('bower_components/bootstrap/dist/fonts/glyphicons-halflings-regular.woff');
app.import('bower_components/bootstrap/dist/fonts/glyphicons-halflings-regular.woff2');

app.import('bower_components/jQuery.dotdotdot/src/js/jquery.dotdotdot.min.js');

if (app.env === 'production') {
  app.import('bower_components/event-source-polyfill/eventsource.js');
} else {
  app.import('bower_components/sinon/index.js');
  app.import('bower_components/underscore/underscore.js');
  app.import('bower_components/ember/ember-template-compiler.js');
}

module.exports = app.toTree();
