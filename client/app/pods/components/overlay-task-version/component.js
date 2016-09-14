import Ember from 'ember';
import { task } from 'ember-concurrency';

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

  selectedSnapshots: task(function * () {
    yield this.fetchSnapshots();
    const apertaTask = this.get('model');
    return {
      v1: apertaTask.getSnapshotForVersion(this.get('selectedVersion1')),
      v2: apertaTask.getSnapshotForVersion(this.get('selectedVersion2'))
    };
  }),

  init() {
    this._super(...arguments);
    this._assertions();
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
