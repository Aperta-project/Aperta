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
import { task as concurrencyTask, timeout } from 'ember-concurrency';

export default Ember.Component.extend(ValidationErrorsMixin, {
  classNameBindings: ['destroyState:_destroy', 'editState:_edit'],

  /**
   * @property figure
   * @type {Figure} Ember.Data model instance
   * @default null
   * @required
   */
  figure: null,
  isEditable: null,

  isUploading: false,
  destroyState: false,
  previewState: false,
  editState: false,
  isProcessing: Ember.computed.equal('figure.status', 'processing'),
  isError: Ember.computed.equal('figure.status', 'error'),
  showSpinner: Ember.computed.or('isProcessing', 'isUploading'),

  uploadErrorMessage: Ember.computed('figure.filename', function() {
    return `There was an error while processing ${this.get('figure.filename')}. Please try again
    or contact Aperta staff.`;
  }),

  validations: {
    'rank': [{
      type: 'inline',
      message: 'Figure label must be unique',
      validation() {
        let rank = this.get('figure.rank');
        if (rank === 0) { return true; }

        // the validation mixin is checking records that
        // are technically destroyed somehow
        // see APERTA-11742 for details
        if (!this.get('figure.paper')) {
          return true;
        }

        let count = this.get('figure.paper.figures').filterBy('rank', rank).get('length');

        return count === 1;
      }
    }]
  },

  rank: Ember.computed('figure.rank', {
    get() {
      return this.get('figure.rank') || 1;
    },
    set(key, value) {
      this.set('figure.title', `Fig ${value}`);
      return value;
    }
  }),

  rankErrorMessage: Ember.computed('figure.paper.figures.@each.rank', function() {
    this.validate('rank');
    return this.get('validationErrors.rank');
  }),

  figureIsUnlabeled: Ember.computed.lt('figure.rank', 1),

  unlabeledFigureMessage: `
    Sorry, we didn't find a figure label in this filename.
    Please edit to add a label. `,

  figureUrl: Ember.computed('figure.id', function() {
    return `/api/figures/${this.get('figure.id')}/update_attachment`;
  }),

  onProcessingFinished: Ember.observer('isProcessing', function() {
    if (!this.get('isProcessing')) {
      this.get('processingFinished')();
    }
  }),

  focusOnFirstInput() {
    Ember.run.schedule('afterRender', this, function() {
      this.$('input[type=text]:first').focus();
    });
  },

  cancelUpload: concurrencyTask(function * () {
    let figure = this.get('figure');
    this.set('isCanceled', true);
    yield figure.cancelUpload();
    yield timeout(5000);
    figure.unloadRecord();
  }),

  willDestroyElement() {
    this._super(...arguments);
    if (this.get('isCanceled') && this.get('figure')) {
      this.get('figure').unloadRecord();
    }
  },

  actions: {
    cancelUpload() {
      this.get('cancelUpload').perform();
    },

    cancelEditing() {
      this.set('editState', false);
      this.get('figure').rollbackAttributes();
    },

    toggleEditState() {
      this.toggleProperty('editState');
      if (this.get('editState')) {
        this.focusOnFirstInput();
      }
    },

    saveFigure() {
      this.get('figure').save();
      this.set('editState', false);
    },

    cancelDestroyFigure() {
      this.set('destroyState', false);
    },

    confirmDestroyFigure() {
      this.set('destroyState', true);
    },

    destroyFigure() {
      this.$().fadeOut(250, ()=> {
        this.get('destroyFigure')(this.get('figure'));
      });
    },

    uploadStarted(data, fileUploadXHR) {
      this.set('isUploading', true);
      this.get('uploadStarted')(data, fileUploadXHR);
    },

    uploadProgress(data) {
      this.get('uploadProgress')(data);
    },

    uploadFinished(data, filename) {
      this.set('isUploading', false);
      this.get('uploadFinished')(data, filename);
    }
  }
});
