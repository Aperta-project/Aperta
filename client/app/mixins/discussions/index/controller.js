import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {

  paper: undefined,

  filteredTopics: Ember.computed('model.[]', 'paperId', function() {
    return this.get('model').filterBy('paperId', this.get('paper.id'));
  }),

  topicSort: ['createdAt:desc'],

  paperTopics: Ember.computed.sort('filteredTopics', 'topicSort'),

});
