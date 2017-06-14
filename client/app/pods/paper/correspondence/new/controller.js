import Ember from 'ember';

export default Ember.Controller.extend({
  // correspondence: Ember.computed.alias('model')

  actions: {
    hideCorrespondenceOverlay() {
      this.send('removeCorrespondenceOverlay');
    }
  }
});
