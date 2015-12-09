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

  snapshot: null,

  init() {
    this._super(...arguments);
    this._assertions();

    this.set('isLoading', true);
    this.fetchSnapshots().then(()=> {
      this.set('snapshot', this.get('model').getSnapshotForVersion(
        this.get('majorVersion'),
        this.get('minorVersion')
      ));

      this.set('isLoading', false);
    });
  },

  fetchSnapshots() {
    return Ember.RSVP.all([this.get('model').get('snapshots')]);
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
