import DS from 'ember-data';

export default DS.Model.extend({
  title: DS.attr('string'),
  query: DS.attr('string'),
  orderDir: DS.attr('string'),
  orderBy: DS.attr('string'),
});
