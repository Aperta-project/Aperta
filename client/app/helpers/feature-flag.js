import Ember from 'ember';

export default Ember.Helper.extend({
  featureFlag: Ember.inject.service(),

  compute([flag]){
    return this.get('featureFlag').value(flag);
  }
});
