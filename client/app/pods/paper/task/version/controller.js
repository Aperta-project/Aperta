import Ember from 'ember';
export default Ember.Controller.extend({
  queryParams: ['majorVersion', 'minorVersion'],

  snapshot: Ember.computed('model', 'majorVersion', 'minorVersion', function(){
    return this.get('model').getSnapshotForVersion(
      this.get('majorVersion'),
      this.get('minorVersion')
    );
  }),

  actions: {
    close() {
      this.transitionToRoute('paper.versions', this.get('model.paper'));
    }
  }
});
