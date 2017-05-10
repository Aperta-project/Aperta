import Ember from 'ember';
import PopoutChildRouteMixin from 'ember-popout/mixins/popout-child-route';

export default Ember.Route.extend(PopoutChildRouteMixin,{
  parentActions: ['popInDiscussions'],
  popinRoute: 'index',
  popinDiscussionId: null,
  setupController() {
    this.controllerFor('application').set('minimalChrome', true);
  },
  actions: {
    popIn() {
      this.send('popInDiscussions',
        {route: this.get('popinRoute'),
          discussionId: this.get('popinDiscussionId')});
      window.close();
    },
    updateRoute(route) {
      this.set('popinRoute', route);
    },
    updateDiscussionId(id) {
      this.set('popinDiscussionId', id);
    }
  }
});
