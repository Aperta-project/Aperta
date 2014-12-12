`import DS from 'ember-data'`

a = DS.attr

Role = DS.Model.extend

  journal: DS.belongsTo('adminJournal')
  userRoles: DS.hasMany('userRole')
  flows: DS.hasMany('flow', async: true)

  name: a('string')
  kind: a('string')
  canAdministerJournal: a('boolean')
  required: a('boolean')
  canViewAssignedManuscriptManagers: a('boolean')
  canViewAllManuscriptManagers: a('boolean')
  canViewFlowManager: a('boolean')

  destroyRecord: ->
    @get('userRoles').invoke('unloadRecord')
    @_super()

`export default Role`
