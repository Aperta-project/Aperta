export default {
  name: 'current-user',
  after: 'ember-data',

  initialize(instance) {
    let data = window.currentUserData;
    if($.isEmptyObject(data)) { return; }

    let store = instance.container.lookup('service:store');
    store.pushPayload(data);

    let user = store.getById('user', data.user.id);
    instance.registry.register('user:current', user, {
      instantiate: false
    });

    instance.registry.injection('controller', 'currentUser', 'user:current');
    instance.registry.injection('route', 'currentUser', 'user:current');
  }
};
