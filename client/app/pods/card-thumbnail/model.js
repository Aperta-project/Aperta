import DS from 'ember-data';

export default DS.Model.extend({
  paper: DS.belongsTo('paper', { async: false }),

  task: DS.belongsTo('task', {
    polymorphic: true,
    async: true
  }),

  commentLooks: DS.hasMany('comment-look', {
    inverse: 'cardThumbnail',
    async: false
  }),

  completed: DS.attr('boolean'),
  createdAt: DS.attr('string'),
  position: DS.attr('number'),
  taskType: DS.attr('string'),
  title: DS.attr('string')
});
