a = DS.attr
ETahi.UserRole = DS.Model.extend
  roleName: a 'string'
  user: DS.belongsTo 'adminJournalUser'
  role: DS.belongsTo 'role'
