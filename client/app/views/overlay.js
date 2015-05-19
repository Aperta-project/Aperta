import Ember from 'ember';
import AnimateElement from 'tahi/mixins/routes/animate-element';

export default Ember.View.extend(AnimateElement, {
  animateIn: function() {
    Ember.run.scheduleOnce('afterRender', this, this.animateOverlayIn);
  }.on('didInsertElement'),

  addExtraClasses: function() {
    $('.overlay').addClass(this.get('controller.overlayClass'));
  }.on('didInsertElement'),

  removeExtraClasses: function() {
    $('.overlay').attr('class', 'overlay');
  }.on('willDestroyElement'),

  setupKeyup: function() {
    $('body').on('keyup.overlay', (e)=> {
      if (e.keyCode === 27 || e.which === 27) {
        if ($(e.target).is(':not(input, textarea)')) {
          this.get('controller').send('closeAction');
        }
      }
    });
  }.on('didInsertElement'),

  tearDownKeyup: function() {
    $('body').off('keyup.overlay');
  }.on('willDestroyElement')
});
