import Ember from 'ember';

export default Ember.Route.extend({
  showDirtyOverlay: false,
  actions: {
    willTransition(transition) {
      var card = this.get('controller.model');
      // copy pasted. refactor
      var cardChanged = card.get('hasDirtyAttributes') && card.changedAttributes()['xml'];

      if(cardChanged) {
        this.set('previousTransition', transition);
        transition.abort();
        this.set('controller.showDirtyOverlay', true);
      } else {
        return true;
      }
    },

    allowStoppedTransition() {
      this.set('controller.showDirtyOverlay', false);
      var transition = this.get('previousTransition');
      this.transitionTo(transition.targetName);
    }
  }
});
