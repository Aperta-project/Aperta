import Ember from 'ember';

export default Ember.Mixin.create({
  setupKeyup: Ember.on('didInsertElement', function() {
    $('body').on('keyup.' + this.get('elementId'), (e)=> {
      if (e.keyCode !== 27 || e.which !== 27) { return; }
      if ($(e.target).is('input, textarea')) { return; }
      this.send('close');
    });
  }),

  tearDownKeyup: Ember.on('willDestroyElement', function() {
    $('body').off('keyup.' + this.get('elementId'));
  })
});
