import Ember from 'ember';

export default Ember.Route.extend({

  filteredTopics: Ember.computed.alias('model.discussionTopics'),

  topicSort: ['createdAt:desc'],

  topicsShowPath: 'discussions.paper.show',
  topicsNewPath: 'discussions.paper.new',

  paperTopics: Ember.computed.sort('filteredTopics', 'topicSort'),

  activate() {
    this.send('updateRoute', 'index');
    this.send('updateDiscussionId', null);
  }

});
