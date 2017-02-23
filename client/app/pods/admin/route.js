import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';


export default AuthorizedRoute.extend({
  beforeModel() {
    return Ember.$.ajax('/api/admin/journals/authorization');
  },

  setupController() {
    this._super(...arguments);
    this.setupPusher();
  },

  setupPusher() {
    let pusher = this.get('pusher');

    // This will bubble up to created and updated actions in the root
    // application route
    pusher.wire(this, 'private-admin', ['created', 'updated', 'destroyed']);
  },

  deactivate() {
    this.get('pusher').unwire(this, 'private-admin');
  },

  _pusherEventsId() {
    // needed for the `wire` and `unwire` method
    // to think we have `ember-pusher/bindings` mixed in
    return this.toString();
  },

  actions: {
    didTransition() {
      $('html').attr('screen', 'private-admin');
      return true;
    },

    willTransition() {
      $('html').attr('screen', '');
      return true;
    }
  }
});
