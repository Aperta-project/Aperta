a = DS.attr
ETahi.Role = DS.Model.extend
  name: a('string')

  admin: a('boolean')
  editor: a('boolean')
  reviewer: a('boolean')

  canAdministerJournal: a('boolean')
  canViewAssignedManuscriptManagers: a('boolean')
  canViewAllManuscriptManagers: a('boolean')

  journal: DS.belongsTo('journal')

  isBuiltIn: Ember.computed.or('admin', 'editor', 'reviewer')
