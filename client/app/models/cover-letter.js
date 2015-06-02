import DS from 'ember-data';

export default DS.Model.extend({
  body: DS.attr('string'),
  paper: DS.belongsTo('paper'),

  createdAt: DS.attr('date')
});
