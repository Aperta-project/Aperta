import Ember from 'ember';

export default Ember.Service.extend({
  store: Ember.inject.service(),

  setup() {
    return this.get('store').findAll('feature-flag');
  },

  value(name) {
    const records = this.get('store').peekAll('feature-flag');
    if(Ember.isEmpty(records)) { return false; }
    return records.findBy('name', name).get('active');
  }
});

