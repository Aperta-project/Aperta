import Ember from 'ember';

export default Ember.Component.extend({
  restless: Ember.inject.service(),
  flags: {},

  actions: {
    save() {
      const output = JSON.parse(JSON.stringify(this.get('flags')));
      this.get('restless').put('/api/feature_flags.json', {
        'feature_flags': output
      });
    }
  }
});
