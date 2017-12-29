import DS from 'ember-data';

export default DS.Model.extend({
  roles: DS.hasMany('admin-journal-role'),
  filterByCardId: DS.attr('string'),
  permissionAction: DS.attr('string')
});
