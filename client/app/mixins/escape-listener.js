import Ember from 'ember';

const ESC_KEY = 27;
const notEscapeKey = function(e) {
  return e.keyCode !== ESC_KEY || e.which !== ESC_KEY;
};

const ofType = 'input, textarea, [contenteditable=true], .select-box-element';
const shouldNotClose = function(e) {
  return Ember.$(e.target).is(ofType);
};

export default Ember.Mixin.create({
  escapeKeyAction: 'close',

  eventName() {
    return 'keyup.' + this.get('elementId');
  },

  setupKeyup: Ember.on('didInsertElement', function() {
    Ember.$('body').on(this.eventName(), (e)=> {
      if (notEscapeKey(e))   { return; }
      if (shouldNotClose(e)) { return; }
      this.send(this.get('escapeKeyAction'));
    });
  }),

  tearDownKeyup: Ember.on('willDestroyElement', function() {
    Ember.$('body').off(this.eventName());
  })
});
