a = DS.attr
ETahi.AdminJournalUser = DS.Model.extend
  userRoles: DS.hasMany('userRole')

  firstName: a('string')
  lastName: a('string')
  username: a('string')
