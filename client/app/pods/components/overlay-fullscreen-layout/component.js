import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['overlay', 'overlay--fullscreen'],

  closeVisible: Ember.computed('enableClose', function() {
    if (this.get('enableClose') === undefined || this.get('enableClose') === true){
      return true;
    }
    else {
      return this.get('enableClose');
    }
  }),

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
