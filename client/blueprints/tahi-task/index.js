var path = require('path');

module.exports = {
  description: 'Creates a new Tahi task.',

  anonymousOptions: [
    'task-name',
    'plugin-path'
  ],

  locals: function(options) {
    var relativePath = path.relative(this.project.root, options.args[2]);
    return {
      tahiPluginPath: relativePath
    };
  },


  fileMapTokens: function(_) {
    return {
      __tahipluginpath__: function(options) {
        return options.locals.tahiPluginPath;
      }
    };
  }
};
