import DS from 'ember-data';

export default DS.Model.extend({
  cardContent: DS.belongsTo('card-content'),
  task: DS.belongsTo('task'),
  answers: DS.hasMany('answer')
});
