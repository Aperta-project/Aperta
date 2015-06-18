import DS from 'ember-data';

export default DS.Model.extend({
  discussionTopic: DS.belongsTo('discussion-topic'),
  user: DS.belongsTo('user'),
});
