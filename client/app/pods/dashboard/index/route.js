import Ember from 'ember';

export default Ember.Route.extend({
  model() {
    return Ember.RSVP.hash({
      papers: this.store.find('paper'),
      invitations: this.store.find('invitation')
    });
  },

  setupController(controller, model) {
    this.store.find('comment-look').then(function(commentLooks) {
      return controller.set('unreadComments', commentLooks);
    });
    controller.set('papers', this.store.filter('paper', function(p) {
      return Ember.isPresent(p.get('oldRoles'));
    }));
    return this._super(controller, model);
  },

  actions: {
    didTransition() {
      this.controllerFor('dashboard.index').set('pageNumber', 1);
      return true;
    }
  }
});
