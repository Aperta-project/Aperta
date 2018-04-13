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
  journal: null,
  classNames: ['admin-journal-settings'],
  settings: [],
  pdfCssSaveStatus: '',
  manuscriptCssSaveStatus: '',
  showEditCSSOverlay: false,
  editCssOverlayName: null,

  flash: Ember.inject.service(),

  journalSelected: Ember.computed('journal', function() {
    return Ember.isPresent(this.get('journal'));
  }),

  actions: {
    showSaveMessage() {
      this.get('flash').displayRouteLevelMessage('success', 'Successfully Saved');
    },

    saveCSS(key, value) {
      this.set('journal.' + key + 'Css', value);
      this.get('journal').save().then(() => {
        this.send('showSaveMessage');
      });
    },

    editCSS(type) {
      this.setProperties({
        showEditCSSOverlay: true,
        css: this.get(`journal.${type}Css`),
        editCssOverlayName: 'edit-journal-' + type + '-css',
      });
    },

    hideEditCSSOverlay() {
      this.set('showEditCSSOverlay', false);
    }
  }
});
