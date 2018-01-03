import Ember from 'ember';

export default Ember.Service.extend(Ember.Evented, {
  publish() {
    return this.trigger.apply(this, arguments);
  },

  subscribe() {
    return this.on.apply(this, arguments);
  },

  unsubscribe() {
    return this.off.apply(this, arguments);
  }
});
