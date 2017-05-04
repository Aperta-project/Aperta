import Ember from 'ember';

export default Ember.Controller.extend({

  filteredTopics: Ember.computed.alias('model.discussionTopics'),

  topicSort: ['createdAt:desc'],

  topicsShowPath: 'discussions.paper.show',
  topicsNewPath: 'discussions.paper.new',

  paperTopics: Ember.computed.sort('filteredTopics', 'topicSort')

});
