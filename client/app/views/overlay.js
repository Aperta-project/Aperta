import Ember from 'ember';
import AnimateOverlay from 'tahi/mixins/animate-overlay';

export default Ember.View.extend(AnimateOverlay, {
  instant: true,

  animateIn: function() {
    let options = {
      extraClasses: this.get('controller.overlayClass'),
      instant: this.get('instant')
    };

    Ember.run.scheduleOnce('afterRender', this, function() {
      this.$().addClass('animation-fade-in');
      this.animateOverlayIn(options);
    });
  }.on('didInsertElement'),

  removeExtraClasses: function() {
    $('.overlay').attr('class', 'overlay');
  }.on('willDestroyElement'),

  setupKeyup: function() {
    $('body').on('keyup.' + this.get('elementId'), (e)=> {
      if (e.keyCode === 27 || e.which === 27) {
        if ($(e.target).is(':not(input, textarea)')) {
          this.get('controller').send('closeAction');
        }
      }
    });
  }.on('didInsertElement'),

  tearDownKeyup: function() {
    $('body').off('keyup.' + this.get('elementId'));
  }.on('willDestroyElement')
});
