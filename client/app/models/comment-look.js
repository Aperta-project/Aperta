import DS from 'ember-data';

export default DS.Model.extend({
  comment: DS.belongsTo('comment'),
  user: DS.belongsTo('user'),

  paperId: DS.attr('string'),
  readAt: DS.attr('date'),
  taskId: DS.attr('string')
});
