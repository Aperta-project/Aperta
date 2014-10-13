ETahi.PaperAdminTask = ETahi.Task.extend
  possibleAdmins: DS.hasMany('user')
  admin: DS.belongsTo('user')
