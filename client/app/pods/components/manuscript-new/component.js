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
import EscapeListenerMixin from 'tahi/mixins/escape-listener';
import checkType, { filetypeRegex } from 'tahi/lib/file-upload/check-filetypes';

const { computed } = Ember;

export default Ember.Component.extend(EscapeListenerMixin, {
  fileTypes: computed('paper.journal.mswordAllowed', function() {
    let allowedFileTypes = ['.pdf'];
    if (this.get('paper.journal.mswordAllowed')) {
      allowedFileTypes.push('.doc', '.docx');
    }
    return allowedFileTypes.join(',');
  }),
  restless: Ember.inject.service(),
  flash: Ember.inject.service(),
  journals: null,
  paper: null,
  isSaving: false,
  journalEmpty: computed.empty('paper.journal.content'),
  hasTitle: computed.notEmpty('paper.title'),

  orderedPaperTypeNames: [
    'Research Article',
    'Short Reports',
    'Methods and Resources',
    'Meta-Research Article',
    'Essay',
    'Perspective',
    'Community Page',
    'Unsolved Mystery',
    'Primer (invitation only)',
    'Research Matters (invitation only)',
    'Formal Comment (invitation only)',
    'Editorial (staff use only)',
    'Open Highlights (staff use only)'
  ],

  // This is a short-term solution for ordering paper types based entirely on
  // PLOS Biology's needs. We expect to replace this with something more
  // user configurable in the future. APERTA-11315
  orderedPaperTypes: Ember.computed('orderedPaperTypeNames.[]', 'paper.journal.manuscriptManagerTemplates.[]', function() {
    const orderedPaperTypes = Ember.A();
    return this.get('paper.journal').then((journal) => {
      if (!journal) { return orderedPaperTypes; }
      const mmts = journal.get('manuscriptManagerTemplates').copy();
      this.get('orderedPaperTypeNames').forEach((name) => {
        const match = mmts.find((mmt) => {
          return mmt.paper_type === name;
        });
        if (match) {
          orderedPaperTypes.push(match);
          mmts.removeObject(match);
        }
      });
      return orderedPaperTypes.pushObjects(mmts.sortBy('paper_type'));
    });
  }),

  actions: {
    titleChanged(contents) {
      this.set('paper.title', contents);
    },

    selectJournal(journal) {
      this.set('paper.journal', journal);
      this.set('paper.paperType', null);
    },

    clearJournal() {
      this.set('paper.journal', null);
      this.set('paper.paperType', null);
    },

    selectPaperType(template) {
      this.set('paper.paperType', template.paper_type);
      this.set('template', template);
    },

    clearPaperType() {
      this.set('paper.paperType', null);
    },

    fileAdded(upload){
      let check = checkType(upload.files[0].name, this.get('fileTypes'));
      if (!check.error) {
        this.set('paper.fileType', check['acceptedFileType']);
        this.set('isSaving', true);
      } else {
        this.set('isSaving', false);
        this.get('flash').displayRouteLevelMessage(check.msg);
      }
    },

    addingFileFailed(reason, message, {fileName, acceptedFileTypes}) {
      this.set('isSaving', false);
      this.get('flash').displayRouteLevelMessage('error', message);
    },

    uploadFinished(s3Url){
      let paper = this.get('paper'),
        template = this.get('template');
      paper.set('url', s3Url);
      paper.save().then((paper) => {
        this.attrs.complete(paper, template);
      } , (response) => {
        this.get('flash').displayErrorMessagesFromResponse(response);
      }).finally(() => {
        this.set('isSaving', false);
      });
    },

    uploadFailed(reason){
      this.set('isSaving', false);
      this.get('flash').displayRouteLevelMessage('error', reason);
      console.log(reason);
    },

    close() {
      this.attrs.close();
    }
  }
});
