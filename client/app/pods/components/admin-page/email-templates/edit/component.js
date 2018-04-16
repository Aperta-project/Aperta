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
import BrowserDirtyEditor from 'tahi/mixins/components/dirty-editor-browser';
import EmberDirtyEditor from 'tahi/mixins/components/dirty-editor-ember';

// This validation works for our pre-populated letter templates
// but we might want to change this up when users are allowed to create
// new templates.

export default Ember.Component.extend(BrowserDirtyEditor, EmberDirtyEditor, {
  store: Ember.inject.service(),
  routing: Ember.inject.service('-routing'),
  saved: true,
  subjectEmpty: false,
  bodyEmpty: false,
  isEditingName: false,

  actions: {
    editTitle() {
      this.set('isEditingName', true);
      if (this.get('template.hasDirtyAttributes')) {
        this.set('saved', false);
      } else {
        this.set('saved', true);
      }
    },

    handleInputChange() {
      this.set('saved', false);
      if(!this.get('template.nameEmpty')) {
        this.set('message', '');
      } else {
        this.setProperties({
          message: 'Please correct errors where indicated.',
          messageType: 'danger'
        });
      }
    },

    checkSubject() {
      if (!this.get('template.subject')) {
        this.set('subjectEmpty', true);
      } else {
        this.set('subjectEmpty', false);
      }
    },

    checkBody() {
      if(!this.get('template.body')) {
        this.set('bodyEmpty', true);
      } else {
        this.set('bodyEmpty', false);
      }
    },

    parseErrors(error) {
      this.get('template').parseErrors(error);
      this.setProperties({
        message: 'Please correct errors where indicated.',
        messageType: 'danger'
      });
    },

    save: function() {
      let template = this.get('template');
      template.clearErrors();
      if (template.get('subject') && template.get('body') && template.get('name')) {
        template.save()
          .then(() => {
            this.setProperties({
              saved: true,
              isEditingName: false,
              message: 'Your changes have been saved.',
              messageType: 'success'
            });
          })
          .catch(error => {
            this.send('parseErrors', error);
          });
      } else {
        this.setProperties({
          message: 'Please correct errors where indicated.',
          messageType: 'danger'
        });
      }
    }
  }
});
