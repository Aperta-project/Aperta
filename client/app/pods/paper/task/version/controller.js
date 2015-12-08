import Ember from 'ember';

export default Ember.Controller.extend({
  queryParams: ['selectedVersion1', 'selectedVersion2'],

  selectedVersion1Snapshot: Ember.computed('model', 'selectedVersion1', function(){
    return this.get('model').getSnapshotForVersion(this.get('selectedVersion1'));
  }),

  selectedVersion2Snapshot: Ember.computed('model', 'selectedVersion2', function(){
    return this.get('model').getSnapshotForVersion(this.get('selectedVersion2'));
  }),

  actions: {
    close() {
      this.transitionToRoute('paper.versions', this.get('model.paper'));
    }
  }
});
