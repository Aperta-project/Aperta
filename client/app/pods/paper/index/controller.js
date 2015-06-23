import Ember from 'ember';
import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBaseMixin, DiscussionsRoutePathsMixin, {
  subRouteName: 'index'
});
