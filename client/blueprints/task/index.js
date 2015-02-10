// copied from the ember-cli string utils (no way to import them)
// we could pretty easily use an npm package like 'inflection' too.

var path = require('path');
var fs   = require('fs');

var dasherize =  function(str) {
    var STRING_DECAMELIZE_REGEXP = (/([a-z\d])([A-Z])/g);
    var STRING_DASHERIZE_REGEXP = (/[ _]/g);

    var dashed = str.replace(STRING_DECAMELIZE_REGEXP, '$1_$2').toLowerCase();
    return dashed.replace(STRING_DASHERIZE_REGEXP,'-');
};

module.exports = {
  description: 'Creates a new task as an in-repo addon.  Make sure to add the file to addons in package.json',

  // locals: function(options) {
  //   // Return custom template variables here.
  //   return {
  //     foo: options.entity.options.foo
  //   };
  // }

  // afterInstall: function(options) {
  //   // Perform extra work here.
  // }
  afterInstall: function(options) {
    var packagePath = path.join(this.project.root, 'package.json');
    var contents    = JSON.parse(fs.readFileSync(packagePath, { encoding: 'utf8' }));
    var name        = dasherize(options.entity.name);
    var newPath     = path.join('lib', name);
    var paths;

    contents['ember-addon'] = contents['ember-addon'] || {};
    paths = contents['ember-addon']['paths'] = contents['ember-addon']['paths'] || [];

    if (paths.indexOf(newPath) === -1) {
      paths.push(newPath);
    }

    fs.writeFileSync(packagePath, JSON.stringify(contents, null, 2));
  }
};
