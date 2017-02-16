import Ember from 'ember';

export default Ember.Helper.extend({
  featureFlag: Ember.inject.service(),

  compute([flag]){
    this.flag = flag;
    const service = this.get('featureFlag');
    service.addObserver(flag, this, 'recompute');
    return service.get(flag);
  },

  destroy() {
    this.get('featureFlag').removeObserver(this.flag, this, 'recompute');
    return this._super();
  }
});
