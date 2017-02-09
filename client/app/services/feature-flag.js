import Ember from 'ember';
const Promise = Ember.RSVP.Promise;

export default Ember.Service.extend({
  restless: Ember.inject.service(),
  callbacks: [],
  ready: false,

  init() {
    this._super(...arguments);
    this.get('restless').get('/api/feature_flags.json').then(
      (flags) => {
        this.setProperties(flags);
        this.set('ready', true);
        this.callbacks.forEach(
          c => { c.callback(flags[c.name]); }
        );
      }
    );
  },

  // return a promise that thens only if the flag is enabled
  enabled(flag) {
    return new Promise((resolve) => {
      if (this.get('ready')) {
        resolve(this.get(flag));
      } else {
        this.callbacks.push({
          name: flag,
          callback:(v) => { if (v) resolve(); }
        });
      }
    });
  },

  // return a promise that thens only if the flag is disabled
  disabled(flag) {
    return new Promise((resolve) => {
      if (this.get('ready')) {
        resolve(this.get(flag));
      } else {
        this.callbacks.push({
          name: flag,
          callback: (v) => { if (!v) resolve(); }
        });
      }
    });
  },

  value(flag) {
    return new Promise((resolve) => {
      if (this.get('ready')) {
        resolve(this.get(flag));
      } else {
        this.callbacks.push({
          name: flag,
          callback: resolve
        });
      }
    });
  }
});
