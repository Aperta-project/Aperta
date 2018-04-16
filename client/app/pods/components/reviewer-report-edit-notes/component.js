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

export default Ember.Component.extend({
  activeEdit: Ember.computed('currentReviewerReport.adminEdits.[]', function() {
    return this.get('currentReviewerReport.adminEdits').findBy('active', true);
  }),
  notesClass: Ember.computed('notesEmpty', function() {
    return this.get('notesEmpty') ? 'form-control error' : 'form-control';
  }),

  actions: {
    cancelEdit() {
      this.set('currentReviewerReport.activeAdminEdit', false);
      this.set('currentReviewerReport.cancelPendingAnswerSaves', true);
      Ember.run(() => {
        this.get('activeEdit').destroyRecord();
        this.get('currentReviewerReport').reload().then(() => {
          this.set('currentReviewerReport.cancelPendingAnswerSaves', false);
        });
      });
    },

    saveEdit() {
      let activeEdit = this.get('activeEdit');
      let notes = activeEdit.get('notes');
      // If Ember thinks the note is empty, or the note contains only whitespace,
      // consider it invalid, and don't save the edit
      if (Ember.isEmpty(notes) || !/\S/.test(notes)) {
        this.set('notesEmpty', true);
      } else {
        let report = this.get('currentReviewerReport');
        activeEdit.set('active', false);
        activeEdit.save().then(function() {
          report.set('activeAdminEdit', false);
        });
      }
    },

    clearNotesError() {
      this.set('notesEmpty', false);
    }
  }
});
