import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['overlay-x', 'overlay-x--fullscreen'],

  init() {
    this._super(...arguments);
      Ember.assert(
        'You must provide a close action to OverlayFullscreenLayout',
         !Ember.isEmpty(this.attrs.close)
      );
  },

  actions: {
    close() {
      this.attrs.close();
    }
  }
});
