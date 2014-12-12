`import DS from 'ember-data'`

a = DS.attr

AdminJournalUser = DS.Model.extend

  userRoles: DS.hasMany('userRole')

  firstName: a('string')
  lastName: a('string')
  username: a('string')

`export default AdminJournalUser`
