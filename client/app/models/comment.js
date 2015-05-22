import DS from 'ember-data';

export default DS.Model.extend({
  commenter: DS.belongsTo('user'),
  commentLook: DS.belongsTo('comment-look', { inverse: 'comment' }),
  task: DS.belongsTo('task', { polymorphic: true }),

  body: DS.attr('string'),
  createdAt: DS.attr('date'),
  entities: DS.attr(),
});
