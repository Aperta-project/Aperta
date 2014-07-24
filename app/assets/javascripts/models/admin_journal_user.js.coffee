a = DS.attr
ETahi.AdminJournalUser = DS.Model.extend
  firstName: a('string')
  lastName: a('string')
  username: a('string')
  userRoles: DS.hasMany('userRole')
