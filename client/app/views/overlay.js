import Ember from 'ember';
import AnimateOverlay from 'tahi/mixins/animate-overlay';

export default Ember.View.extend(AnimateOverlay, {
  animateIn: function() {
    Ember.run.scheduleOnce('afterRender', this, this.animateOverlayIn);
  }.on('didInsertElement'),

  setupKeyup: (function() {
    $('body').on('keyup.overlay', (e)=> {
      if (e.keyCode === 27 || e.which === 27) {
        if ($(e.target).is(':not(input, textarea)')) {
          this.get('controller').send('closeAction');
        }
      }
    });
  }).on('didInsertElement'),

  tearDownKeyup: function() {
    $('body').off('keyup.overlay');
  }.on('willDestroyElement')
});
