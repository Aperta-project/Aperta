import Ember from 'ember';

export default Ember.Component.extend({
  attributeBindings: ['contenteditable', 'placeholder'],
  editable: true,
  placeholder: '',
  plaintext: false,
  preventEnterKey: false,
  _userIsTyping: false,

  setup: Ember.on('didInsertElement', function() {
    this.setHTMLFromValue();
    if (this.elementIsEmpty() && this.get('placeholder')) {
      this.setPlaceholder();
    }
  }),

  contenteditable: Ember.computed('editable', function() {
    return this.get('editable') ? 'true' : undefined;
  }),

  valueDidChange: Ember.observer('value', function() {
    if (this.get('value') && !this.get('_userIsTyping')) {
      this.setHTMLFromValue();
    }
  }),

  keyDown(event) {
    this.set('_userIsTyping', true);
    if (this.get('preventEnterKey')) {
      this.supressEnterKeyEvent(event);
    }
    if (this.elementHasPlaceholder()) {
      this.removePlaceholder();
    }
  },

  keyUp() {
    if (this.elementIsEmpty() || this.elementHasPlaceholder()) {
      this.set('value', '');
      this.setPlaceholder();
      return;
    }
    this.setValueFromHTML();
  },

  focusIn() {
    const action = this.attrs['focus-in'];
    if(action) { action(); }
  },

  focusOut() {
    this.set('_userIsTyping', false);
    if (this.elementIsEmpty()) {
      this.setPlaceholder();
    }

    const action = this.attrs['focus-out'];
    if(action) { action(); }
  },

  elementIsEmpty() {
    return Ember.isEmpty(this.$().text());
  },

  elementHasPlaceholder() {
    return this.$().text() === this.get('placeholder');
  },

  setPlaceholder() {
    this.$().text(this.get('placeholder'));
    this.mute();
  },

  removePlaceholder() {
    this.$().text('');
    this.unmute();
  },

  setHTMLFromValue() {
    if (!this.$()) { return; }
    this.$().html(this.get('value'));
    this.unmute();
  },

  mute() {
    this.$().addClass('content-editable-muted');
  },

  unmute() {
    this.$().removeClass('content-editable-muted');
  },

  setValueFromHTML() {
    if (this.get('plaintext')) {
      this.set('value', this.$().text());
    } else {
      this.set('value', this.$().html());
    }
  },

  supressEnterKeyEvent(e) {
    if (e.keyCode === 13 || e.which === 13) {
      e.preventDefault();
    }
  }
});
