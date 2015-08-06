import DS from 'ember-data';

export default DS.Model.extend({
  user: DS.belongsTo('admin-journal-user', { async: false }),
  role: DS.belongsTo('role', { async: false })
});
