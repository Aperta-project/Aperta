import Ember from 'ember';

export default Ember.Controller.extend({
  routing: Ember.inject.service('-routing'),
  actions: {
    hideCorrespondenceOverlay() {
      this.get('routing.router.router')
          .updateURL(this.get('previousURL'));
      this.send('removeCorrespondenceOverlay');
    }
  }
});
