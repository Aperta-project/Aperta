a = DS.attr
ETahi.UserRole = DS.Model.extend
  user: DS.belongsTo 'adminJournalUser'
  role: DS.belongsTo 'role'
