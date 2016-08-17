/**
* A full-overlay-verification is a confirmation dialog that covers a
* whole task overlay; it's big, it's green, and it's got centered text
* and two buttons. Pass in a question (string), a confirm action, and a
* cancel action.
*/

import Ember from 'ember';

const ESC_KEY = 27;
const escapeKey = function(e) {
  return e.keyCode === ESC_KEY || e.which === ESC_KEY;
};

export default Ember.Component.extend({
  classNames: ['full-overlay-verification'],

  confirmText: 'Yes',
  cancelText: 'Cancel',
  cancel: null, // action run on cancel
  confirm: null, // action run on confirm

  eventName() {
    return 'keyup.' + this.get('elementId');
  },

  setupEscapeListener: Ember.on('didInsertElement', function() {
    Ember.$('body').on(this.eventName(), (e)=> {
      if (escapeKey(e)) {
        this.sendAction('cancel');
      }
    });
  }),

  tearDownEscapeListener: Ember.on('willDestroyElement', function() {
    Ember.$('body').off(this.eventName());
  })

});
