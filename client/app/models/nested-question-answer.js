import DS from 'ember-data';

export default DS.Model.extend({
  task: DS.belongsTo('task', {
    polymorphic: true,
    async: false
  }),
  nestedQuestion: DS.belongsTo('nested-question', { async: false, inverse: 'answers' }),
  value: DS.attr(),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),
});
