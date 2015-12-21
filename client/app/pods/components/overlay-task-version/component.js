import Ember from 'ember';

export default Ember.Component.extend({
  /**
   *  Method called after out animation is complete.
   *  This should be set to an action.
   *  This method is passed to `overlay-animate`
   *
   *  @method outAnimationComplete
   *  @required
  **/
  outAnimationComplete: null,

  isLoading: false,

  selectedVersion1Snapshot: null,
  selectedVersion2Snapshot: null,

  init() {
    this._super(...arguments);
    this._assertions();
    const task = this.get('model');

    this.set('isLoading', true);
    this.fetchSnapshots().then(()=> {
      this.setProperties({
        selectedVersion1Snapshot: task.getSnapshotForVersion(this.get('selectedVersion1')),
        selectedVersion2Snapshot: task.getSnapshotForVersion(this.get('selectedVersion2'))
      });
      this.set('isLoading', false);
    });
  },

  fetchSnapshots() {
    return this.get('model').get('snapshots');
  },

  _assertions() {
    Ember.assert(
      `You must provide an outAnimationComplete
       action to OverlayTaskVersionComponent`,
      !Ember.isEmpty(this.get('outAnimationComplete'))
    );

    Ember.assert(
      `You must provide a model
       action to OverlayTaskVersionComponent`,
      !Ember.isEmpty(this.get('model'))
    );
  },

  actions: {
    close() {
      this.attrs.outAnimationComplete();
    }
  }
});
