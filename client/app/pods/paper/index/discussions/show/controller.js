import Ember from 'ember';
import DiscussionsShowControllerMixin from 'tahi/mixins/discussions/show/controller';

export default Ember.Controller.extend(DiscussionsShowControllerMixin, {
  // required to generate route paths:
  subRouteName: 'index'
});
