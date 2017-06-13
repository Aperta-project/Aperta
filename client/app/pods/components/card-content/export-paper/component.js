import Ember from 'ember';

export default Ember.Component.extend({
  store: Ember.inject.service(),
  task: Ember.computed.reads('owner'),
  actions: {
    sendToApex: function() {
      const apexDelivery = this.get('store').createRecord('apex-delivery', {
        task: this.get('task'),
        destination: this.get('content.text')
      });
      apexDelivery.save();
    }
  }
});
