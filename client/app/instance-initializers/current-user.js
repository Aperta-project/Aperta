export default {
  name: 'current-user',

  initialize(instance) {
    const data = window.currentUserData;
    if($.isEmptyObject(data)) { return; }

    const store = instance.container.lookup('service:store');
    store.pushPayload(data);

    let user = store.peekRecord('user', data.user.id);
    instance.registry.register('user:current', user, {
      instantiate: false
    });

    instance.registry.injection('controller', 'currentUser', 'user:current');
    instance.registry.injection('route',      'currentUser', 'user:current');
    instance.registry.injection('component', 'currentUser', 'user:current');
    instance.registry.injection('service:notifications', 'currentUser',  'user:current');
  }
};
