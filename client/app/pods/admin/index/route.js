import Ember from 'ember';

export default Ember.Route.extend({
  featureFlag: Ember.inject.service(),

  beforeModel() {
    this.get('featureFlag').value('CARD_CONFIGURATION').then((enabled) => {
      if(enabled) {
        this.transitionTo('admin.cc.journals');
      } else {
        this.transitionTo('admin.journals');
      }
    });
  }
});
