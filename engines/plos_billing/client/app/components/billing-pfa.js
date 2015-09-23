import Ember from 'ember';

export default Ember.Component.extend({
  billingController: null, //passed in, avoids sendAction
  onDidInsertElement: Ember.on('didInsertElement', function() {
    //this.billingController.setPfaValidators();
    this.billingController.setPfaDataObjects();
  })
});
