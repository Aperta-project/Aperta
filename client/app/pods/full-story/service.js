import Ember from 'ember';

export default Ember.Service.extend({
  identify(user) {
    if (this._fullStoryInactive()) { return; }
    window.FS.identify(user.get('username'), {
      displayName: user.get('fullName'),
      email: user.get('email')
    });
  },

  clearSession() {
    if (this._fullStoryInactive()) { return; }
    window.FS.clearUserCookie();
  },

  _fullStoryInactive() {
    return (typeof window.FS === 'undefined');
  }
});
