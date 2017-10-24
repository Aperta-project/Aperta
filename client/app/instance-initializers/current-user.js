export default {
  name: 'current-user',

  initialize(instance) {
    const data = window.currentUserData;
    if($.isEmptyObject(data)) { return; }

    const store = instance.lookup('service:store');
    store.pushPayload(data);

    let user = store.peekRecord('user', data.user.id);
    instance.register('service:currentUser', user, {
      instantiate: false
    });

    instance.inject('controller', 'currentUser', 'service:currentUser');
    instance.inject('route',      'currentUser', 'service:currentUser');
    instance.inject('component', 'currentUser', 'service:currentUser');
    instance.inject('model:author', 'currentUser', 'service:currentUser');
    instance.inject('service:notifications', 'currentUser',  'service:currentUser');
  }
};
