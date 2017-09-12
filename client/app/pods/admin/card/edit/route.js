import Ember from 'ember';

export default Ember.Route.extend({
  showDirtyOverlay: false,
  actions: {
    willTransition(transition) {
      let card = this.get('controller.model');
      let hasDirtyXml = !!(card.get('hasDirtyAttributes') && card.changedAttributes()['xml']);

      if(hasDirtyXml) {
        this.set('previousTransition', transition);
        transition.abort();
        this.set('controller.showDirtyOverlay', true);
      } else {
        return true;
      }
    },

    allowStoppedTransition() {
      this.set('controller.showDirtyOverlay', false);
      let transition = this.get('previousTransition');
      transition.retry();
    }
  }
});
