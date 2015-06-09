import DS from 'ember-data';

export default DS.Model.extend({
  discussionTopic: DS.belongsTo('discussion-topic'),
  replier: DS.belongsTo('user'),

  body: DS.attr('string'),
  createdAt: DS.attr('date')
});
