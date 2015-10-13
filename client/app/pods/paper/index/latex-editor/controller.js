import Ember from 'ember';
import PaperBaseMixin from 'tahi/mixins/controllers/paper-base';
import PaperIndexMixin from 'tahi/mixins/controllers/paper-index';
import DiscussionsRoutePathsMixin from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(
  PaperBaseMixin, PaperIndexMixin, DiscussionsRoutePathsMixin, {
  subRouteName: 'index'
});
