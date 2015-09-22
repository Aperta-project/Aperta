import Ember from 'ember';

const heartbeat = Ember.Object.extend({
  interval: 90 * 1000,
  intervalId: null,
  resource: null,

  start() {
    this.heartbeat();
    const heartbeatWrapper = ()=> { return this.heartbeat(); };

    return this.set(
      'intervalId',
      setInterval(heartbeatWrapper, this.get('interval'))
    );
  },

  stop() {
    if (this.get('intervalId')) {
      clearInterval(this.get('intervalId'));
      this.set('intervalId', null);
    }
  },

  heartbeat() {
    return this.get('restless').putModel(this.get('resource'), '/heartbeat');
  }
});

export default Ember.Service.extend({
  restless: Ember.inject.service('restless'),

  create(resource) {
    Ember.assert(
      'Heartbeat: need to specify resource',
      !Ember.isEmpty(resource)
    );

    return heartbeat.create({
      resource: resource,
      restless: this.get('restless')
    });
  }
});
