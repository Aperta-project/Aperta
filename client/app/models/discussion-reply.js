import DS from 'ember-data';

export default DS.Model.extend({
  discussionTopic: DS.belongsTo('discussion-topic', { async: false }),
  replier: DS.belongsTo('user', { async: false }),

  body: DS.attr('string'),
  createdAt: DS.attr('date')
});
