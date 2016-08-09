import DS from 'ember-data';

export default DS.Model.extend({
  firstName: DS.attr('string'),
  lastName:  DS.attr('string'),
  username:  DS.attr('string'),
  adminJournalRoles: DS.hasMany('admin-journal-role')
});
