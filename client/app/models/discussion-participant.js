import DS from 'ember-data';

export default DS.Model.extend({
  discussionTopic: DS.belongsTo('discussion-topic', { async: false }),
  user: DS.belongsTo('user', { async: false })
});
