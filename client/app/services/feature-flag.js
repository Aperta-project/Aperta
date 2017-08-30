import Ember from 'ember';

export default Ember.Service.extend({
  store: Ember.inject.service(),

  setup() {
    return this.get('store').findAll('feature-flag');
  },

  value(name) {
    const records = this.get('store').peekAll('feature-flag');
    if(!records || records.get('length') === 0) { return false; }
    return records.filterBy('name', name)[0].get('active');
  }
});
