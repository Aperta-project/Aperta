import Ember from 'ember';

export default Ember.Component.extend({
  classNameBindings: [':format-input', 'active:format-input--active'],

  // -- attrs:
  // value,
  // placeholder

  displayBold: true,
  displayItalic: true,
  displaySuperscript: true,
  displaySubscript: true,
  displayRemove: true,

  blur(event) {
    const target = Ember.$(event.target);

    if(target.hasClass('.format-input-field')) {
      this.set('active', false);
    }
  },

  bold()        { document.execCommand('bold',         false, null); },
  italic()      { document.execCommand('italic',       false, null); },
  superscript() { document.execCommand('superscript',  false, null); },
  subscript()   { document.execCommand('subscript',    false, null); },
  remove()      { document.execCommand('removeFormat', false, null); },

  actions: {
    format(type) {
      this[type]();
    },

    'focus-in': function() {
      this.set('active', true);
    },

    'focus-out': function() {
      this.set('active', false);
    }
  }
});
