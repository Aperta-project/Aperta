import FactoryGuy from 'ember-data-factory-guy';

FactoryGuy.define('discussion-topic', {
  default: {
    title: 'Tech Check Discussion'
  },

  topic_with_replies: {
    discussionReplies: FactoryGuy.hasMany('discussion-reply', 2)
  }
});
