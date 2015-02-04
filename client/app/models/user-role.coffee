`import DS from 'ember-data'`

a = DS.attr

UserRole = DS.Model.extend

  user: DS.belongsTo 'adminJournalUser'
  role: DS.belongsTo 'role'

`export default UserRole`
