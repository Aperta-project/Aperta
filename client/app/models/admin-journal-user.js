import DS from 'ember-data';

export default DS.Model.extend({
  userRoles: DS.hasMany('user-role'),
  firstName: DS.attr('string'),
  lastName:  DS.attr('string'),
  username:  DS.attr('string')
});
