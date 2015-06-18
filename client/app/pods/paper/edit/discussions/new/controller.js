import Ember from 'ember';
import DiscussionsNewControllerMixin from 'tahi/mixins/discussions/new/controller';

export default Ember.Controller.extend(DiscussionsNewControllerMixin, {
  // required to generate route paths:
  subRouteName: 'edit'
});
