import DS from 'ember-data';

export default DS.Model.extend({
  commenter: DS.belongsTo('user', { async: false }),
  commentLook: DS.belongsTo('comment-look', {
    inverse: 'comment',
    async: false
  }),
  task: DS.belongsTo('task', {
    polymorphic: true,
    async: false
  }),

  body: DS.attr('string'),
  createdAt: DS.attr('date'),
  entities: DS.attr(),
});
