import DS from 'ember-data';

export default DS.Model.extend({
  task: DS.belongsTo('task', {
    polymorphic: true,
    async: false
  }),
  ident: DS.attr('string'),
  position: DS.attr('number'),
  value: DS.attr(),
  value_type: DS.attr('string'),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),

  text: DS.attr('string'),
  children: DS.hasMany('nested-question', { async: false, type: 'nested-question' })
});
