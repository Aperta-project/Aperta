import DS from 'ember-data';

export default DS.Model.extend({
  journal: DS.belongsTo('admin-journal'),
  name: DS.attr('string'),
  content: DS.belongsTo('card-content', { async: false }),
  xml: DS.attr('string')
});
