import DS from 'ember-data';

export default DS.Model.extend({
  user: DS.belongsTo('user'),
  paper: DS.belongsTo('paper'),
  role: DS.attr('string'),
  createdAt: DS.attr('date')
});
