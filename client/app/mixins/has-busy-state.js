import Ember from 'ember';

export default Ember.Mixin.create({
  busy: false,

  // Sets busy state, then returns a promise that will resolve when the busy
  // state has been set and the promise parameter resolves and will finally
  // unset the busy state.
  busyWhile(promise) {
    let setBusy = new Ember.RSVP.Promise((resolve) => {
      this.set('busy', true);
      resolve();
    });
    return Ember.RSVP.all([setBusy, promise]).finally(()=> { this.set('busy', false); } );
  }
});
