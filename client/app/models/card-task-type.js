import DS from 'ember-data';

export default DS.Model.extend({
  displayName: DS.attr('string'),
  taskClass: DS.attr('string')
});
