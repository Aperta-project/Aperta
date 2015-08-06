import Ember from 'ember';
import AnimateOverlay from 'tahi/mixins/animate-overlay';

export default Ember.View.extend(AnimateOverlay, {
  skipAnimation: true,

  animateIn: Ember.on('didInsertElement', function() {
    let options = {
      extraClasses: this.get('controller.overlayClass'),
      skipAnimation: this.get('skipAnimation')
    };

    Ember.run.scheduleOnce('afterRender', this, function() {
      this.$().addClass('animation-fade-in');
      this.animateOverlayIn(options);
    });
  }),

  removeExtraClasses: Ember.on('willDestroyElement', function() {
    $('.overlay').attr('class', 'overlay');
  }),

  setupKeyup: Ember.on('didInsertElement', function() {
    $('body').on('keyup.' + this.get('elementId'), (e)=> {
      if (e.keyCode === 27 || e.which === 27) {
        if ($(e.target).is(':not(input, textarea)')) {
          this.get('controller').send('closeAction');
        }
      }
    });
  }),

  tearDownKeyup: Ember.on('willDestroyElement', function() {
    $('body').off('keyup.' + this.get('elementId'));
  })
});
