import Ember from 'ember';

export default Ember.Controller.extend({

  filteredTopics: Ember.computed.alias('model.discussionTopics'),

  topicSort: ['createdAt:desc'],

  paperTopics: Ember.computed.sort('filteredTopics', 'topicSort')

});
