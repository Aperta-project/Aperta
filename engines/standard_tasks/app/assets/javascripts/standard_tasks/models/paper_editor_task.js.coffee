ETahi.PaperEditorTask = ETahi.Task.extend
  possibleEditors: DS.hasMany('user')
  editor: DS.belongsTo('user')
