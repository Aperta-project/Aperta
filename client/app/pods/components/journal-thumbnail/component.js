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
import FileUploadMixin from 'tahi/mixins/file-upload';
import ValidationErrorsMixin from 'tahi/mixins/validation-errors';

export default Ember.Component.extend(FileUploadMixin, ValidationErrorsMixin, {
  classNames: ['journal-thumbnail'],
  canEdit: null,   // passed-in,
  journal: null,   // passed-in,
  isEditing: false,
  isCreating: false,
  isSaving: false,
  showForm: Ember.computed.or('isEditing', 'isCreating', 'journal.isNew'),

  setJournalProperties() {
    const desc = this.get('journal.description') || '';
    let name = this.get('journal.name') || '';
    this.get('journal').setProperties({
      name: name.trim(),
      description: desc.trim() || null
    });
  },

  stopEditing() {
    this.setProperties({
      isEditing: false,
      isCreating: false
    });
  },

  saveJournal() {
    this.set('isSaving', true);
    this.setJournalProperties();

    this.get('journal').save().then(()=> {
      this.stopEditing();
      this.clearAllValidationErrors();
      if(this.get('afterSave')) {
        this.get('afterSave')();
      }
    }, (response) => {
      this.displayValidationErrorsFromResponse(response);
    }).finally(() => {
      this.set('isSaving', false);
    });
  },

  actions: {

    editJournal() {
      this.set('isEditing', true);
    },

    saveJournalDetails() {
      if(this.get('journal.isNew')) {

        this.set('isCreating', true);
        this.setJournalProperties();

        this.get('journal').save().then(() => {
          this.clearAllValidationErrors();
          return (this.stopEditing).call(this);
        }, (response) => {
          this.clearAllValidationErrors();
          this.displayValidationErrorsFromResponse(response);
        });

      } else {
        this.saveJournal();
      }
    },

    cancel() {
      this.get('journal').rollbackAttributes();
      this.stopEditing();
      this.clearAllValidationErrors();
    },

  }
});
