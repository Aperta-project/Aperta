import Ember from 'ember';

const { computed, observer, on } = Ember;

export default Ember.Component.extend({
  attributeBindings: ['contenteditable', 'placeholder'],
  editable: true,
  placeholder: '',
  plaintext: false,
  preventEnterKey: false,
  _savedRange: null,
  _savedSelection: null,
  _userIsTyping: false,

  _valueAndPlaceholderSetup: on('didInsertElement', function() {
    this.setHTMLFromValue();
    if (this.elementIsEmpty() && this.get('placeholder')) {
      this.setPlaceholder();
    }
  }),

  _setupSelectEvent: on('didInsertElement', function() {
    const eventName = 'selectionchange.' + this.elementId;
    const me = this.$();

    $(document).on(eventName, (event)=> {
      if (event.currentTarget && event.currentTarget.activeElement) {
        if($(event.currentTarget.activeElement).is(me)) {
          this.selectionIn();
        } else {
          this.selectionOut();
        }
      }
    });
  }),

  _teardownSelectEvent: on('willDestroyElement', function() {
    const eventName = 'selectionchange.' + this.elementId;
    $(document).off(eventName);
  }),

  contenteditable: computed('editable', function() {
    return this.get('editable') ? 'true' : undefined;
  }),

  valueDidChange: observer('value', function() {
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

  selectionIn() {
    const action = this.attrs['selection-in'];
    if(action) { action(); }
  },

  selectionOut() {
    const action = this.attrs['selection-out'];
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

  mute() {
    this.$().addClass('content-editable-muted');
  },

  unmute() {
    this.$().removeClass('content-editable-muted');
  },

  setHTMLFromValue() {
    if (!this.$()) { return; }
    const html = this.$().html();
    const value = this.get('value');

    // Don't force DOM changes. It's possible markup and value were
    // changed from an outside component.
    if(html !== value) {
      this.$().html(value);
    }

    this.unmute();
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
