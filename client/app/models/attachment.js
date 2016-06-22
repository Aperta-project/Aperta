import DS from 'ember-data';

export default DS.Model.extend({
  task: DS.belongsTo('task', { async: false, polymorphic: true, inverse: 'attachments' }),
  caption: DS.attr('string'),
  filename: DS.attr('string'),
  kind: DS.attr('string'),
  status: DS.attr('string'),
  title: DS.attr('string')
});
