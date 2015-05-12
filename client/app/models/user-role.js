import DS from 'ember-data';

export default DS.Model.extend({
  user: DS.belongsTo('adminJournalUser'),
  role: DS.belongsTo('role')
});
