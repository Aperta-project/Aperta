a = DS.attr
ETahi.Role = DS.Model.extend
  name: a('string')
  kind: a('string')
  canAdministerJournal: a('boolean')
  required: a('boolean')
  canViewAssignedManuscriptManagers: a('boolean')
  canViewAllManuscriptManagers: a('boolean')
  canViewFlowManager: a('boolean')

  journal: DS.belongsTo('adminJournal')
  userRoles: DS.hasMany('userRole')
