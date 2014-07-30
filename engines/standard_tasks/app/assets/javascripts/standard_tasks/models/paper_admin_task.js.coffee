ETahi.PaperAdminTask = ETahi.Task.extend
  admins: DS.hasMany('user')
  admin: DS.belongsTo('user')

