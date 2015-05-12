import DS from 'ember-data';

export default DS.Model.extend({
  question: DS.belongsTo('question'),

  filename: DS.attr('string'),
  src: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string')
});
