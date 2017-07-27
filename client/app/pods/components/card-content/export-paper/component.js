import Ember from 'ember';

export default Ember.Component.extend({
  owner: null, //owner
  content: null, //card content
  disabled: false,
  store: Ember.inject.service(),
  task: Ember.computed.reads('owner'),
  destination: Ember.computed.reads('content.text'),
  actions: {
    sendToApex: function() {
      if (this.get('disabled')) {
        return;
      }
      const apexDelivery = this.get('store').createRecord('apex-delivery', {
        task: this.get('task'),
        destination: this.get('destination')
      });
      apexDelivery.save();
    }
  }
});
