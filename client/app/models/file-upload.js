import Ember from 'ember';

export default Ember.Object.extend({
  dataLoaded: 0,
  dataTotal: 0,
  file: null,
  preview: null,
  xhr: null,

  abort() {
    if(!this.get('xhr')) { return; }
    this.get('xhr').abort();
  }
});
