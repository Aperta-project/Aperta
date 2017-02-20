import DS from 'ember-data';

export default DS.Model.extend({
  contentRoot: DS.belongsTo('card-content'),
  cardContent: DS.hasMany('card-content'),
  journal: DS.belongsTo('admin-journal'),
  name: DS.attr('string')
});
