import DS from 'ember-data';

export default DS.Model.extend({
  card: DS.belongsTo('card'),
  contentRoot: DS.belongsTo('card-content', { async: false })
});
