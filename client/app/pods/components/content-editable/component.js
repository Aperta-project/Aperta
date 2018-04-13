/**
 * Copyright (c) 2018 Public Library of Science
 *
 * Permission is hereby granted, free of charge, to any person obtaining a
 * copy of this software and associated documentation files (the "Software"),
 * to deal in the Software without restriction, including without limitation
 * the rights to use, copy, modify, merge, publish, distribute, sublicense,
 * and/or sell copies of the Software, and to permit persons to whom the
 * Software is furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
 * THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
 * FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
 * DEALINGS IN THE SOFTWARE.
*/

import Ember from 'ember';

const { computed, observer, on } = Ember;

export default Ember.Component.extend({
  attributeBindings: ['contenteditable', 'placeholder', 'disabled', 'content.isRequired:required', 'aria-required'],
  'aria-required': Ember.computed.reads('content.isRequiredString'),
  editable: true,
  placeholder: '',
  plaintext: false,
  preventEnterKey: false,
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

  autofocus: false,
  _focus: Ember.on('didInsertElement', function() {
    Ember.run.scheduleOnce('afterRender', ()=> {
      if(this.get('autofocus')) { this.$().focus(); }
    });
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

    const action = this.get('key-up');
    if(action) { action(); }
  },

  focusIn() {
    const action = this.get('focus-in');
    if(action) { action(); }
  },

  focusOut() {
    this.set('_userIsTyping', false);
    if (this.elementIsEmpty()) {
      this.setPlaceholder();
    }

    const action = this.get('focus-out');
    if(action) { action(); }
  },

  selectionIn() {
    const action = this.get('selection-in');
    if(action) { action(); }
  },

  selectionOut() {
    const action = this.get('selection-out');
    if(action) { action(); }
  },

  elementIsEmpty() {
    return Ember.isEmpty(this.$().text());
  },

  elementHasPlaceholder() {
    return this.$().text() === this.get('placeholder');
  },

  setPlaceholder() {
    if(this.get('placeholder')) {
      this.$().text(this.get('placeholder'));
      this.mute();
    }
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
    this.set('value', this.$()[ this.get('plaintext') ? 'text' : 'html' ]());
  },

  supressEnterKeyEvent(e) {
    if (e.keyCode === 13 || e.which === 13) {
      e.preventDefault();
    }
  }
});
