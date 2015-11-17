import Ember from 'ember';
import AuthorizedRoute from 'tahi/routes/authorized';

export default AuthorizedRoute.extend({
  beforeModel() {
    return Ember.$.ajax('/api/admin/journals/authorization');
  },

  actions: {
    didTransition() {
      $('html').attr('screen', 'admin');
      return true;
    },

    willTransition() {
      $('html').attr('screen', '');
      return true;
    }
  }
});
