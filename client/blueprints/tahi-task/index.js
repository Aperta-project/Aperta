var path = require('path');

module.exports = {
  description: 'Creates a new Tahi task.',

  anonymousOptions: [
    'task-name',
    'plugin-path',
    'classified-engine-name',
    'underscored-engine-name'
  ],

  locals: function(options) {
    var relativePath = path.relative(this.project.root, options.args[2]);
    return {
      enginePath: relativePath,
      classifiedEngineName: options.args[3],
      underscoredEngineName: options.args[4],
      humanizedModuleName: options.args[1].replace(/\-/g, " ")
    };
  },


  fileMapTokens: function(_) {
    return {
      __enginepath__: function(options) {
        return options.locals.enginePath;
      },
      __engine__: function(options) {
        return options.locals.underscoredEngineName;
      }
    };
  }
};
