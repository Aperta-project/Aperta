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
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNameBindings: [':admin-role', 'isEditing:is-editing:not-editing'],
  isEditing: false,
  notEditing: Ember.computed.not('isEditing'),

  setIsEditing: Ember.on('init', function() {
    if(this.get('model.isNew')) {
      this.set('isEditing', true);
    }
  }),

  _animateInIfNewRole: Ember.on('didInsertElement', function() {
    if (this.get('model.isNew')) {
      this.$().hide().fadeIn(250);
    }
  }),

  focusObserver: Ember.observer('isEditing', function() {
    if (!this.get('isEditing')) { return; }
    Ember.run.schedule('afterRender', this, function() {
      this.$('input:first').focus();
    });
  }),

  click(e) {
    if (!this.get('isEditing')) {
      this.set('isEditing', true);
      e.stopPropagation();
    }
  },

  actions: {
    edit() {
      this.set('isEditing', true);
    },

    save() {
      this.get('model').save().then(()=> {
        this.set('isEditing', false);
      }, (response)=> {
        this.displayValidationErrorsFromResponse(response);
      });
    },

    cancel() {
      this.get('model')[this.get('model.isNew') ? 'deleteRecord' : 'rollbackAttributes']();
      this.set('isEditing', false);
    },

    deleteRole() {
      this.get('model').destroyRecord();
    }
  }
});
