export default {
  name: 'currentUser',
  after: 'store',
  initialize: function(container, application) {
    let data = window.currentUserData;

    if (data) {
      let store = container.lookup('store:main');
      store.pushPayload(data);
      let user = store.getById('user', data.user.id);
      container.register('user:current', user, {
        instantiate: false
      });
      application.inject('controller', 'currentUser', 'user:current');
      application.inject('route', 'currentUser', 'user:current');
    }
  }
};
