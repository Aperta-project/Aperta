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
  authorsTask: Ember.computed(function() {
    return this.get('model.title') === 'Authors';
  }),

  init() {
    this._super(...arguments);
    this._assertions();
    const task = this.get('model');

    this.set('selectedSnapshots', this.fetchSnapshots().then(()=> {
      return {
        v1: task.getSnapshotForVersion(this.get('selectedVersion1')),
        v2: task.getSnapshotForVersion(this.get('selectedVersion2'))
      };
    }));
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
