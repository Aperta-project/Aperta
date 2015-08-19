import Ember from 'ember';
import DiscussionsIndexControllerMixin from 'tahi/mixins/discussions/index/controller';

export default Ember.Controller.extend(DiscussionsIndexControllerMixin, {
  // required to generate route paths:
  subRouteName: 'index'
});
