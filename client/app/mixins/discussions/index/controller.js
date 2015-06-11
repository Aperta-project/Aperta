import Ember from 'ember';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Mixin.create(DiscussionsRoutePathsMixin, {

  paperId: undefined,

  paperTopics: Ember.computed('model.@each', function() {
    return this.get('model').filterBy('paperId', this.get('paperId'));
  }),

});
