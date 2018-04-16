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
import { PropTypes } from 'ember-prop-types';
import { task } from 'ember-concurrency';
import BrowserDirtyEditor from 'tahi/mixins/components/dirty-editor-browser';
import EmberDirtyEditor from 'tahi/mixins/components/dirty-editor-ember';

export default Ember.Component.extend(BrowserDirtyEditor, EmberDirtyEditor, {
  routing: Ember.inject.service('-routing'),
  propTypes: {
    card: PropTypes.EmberObject
  },
  errors: null,
  showPublishOverlay: false,
  showArchiveOverlay: false,
  showDeleteOverlay: false,

  actionIsRunning: Ember.computed.or('saveCard.isRunning', 'publishCard.isRunning', 'revertCard.isRunning'),

  disableRevert: Ember.computed('actionIsRunning', 'editorIsDirty', function() {
    return this.get('editorIsDirty') || this.get('actionIsRunning');
  }),

  disableSave: Ember.computed('actionIsRunning', 'editorIsDirty', function() {
    return !this.get('editorIsDirty') || this.get('actionIsRunning');
  }),

  disablePublish: Ember.computed('actionIsRunning', 'editorIsDirty', 'card.publishable', function() {
    return this.get('editorIsDirty') || !(this.get('card.publishable')) || this.get('actionIsRunning');
  }),

  historyEntryBlank: Ember.computed.empty('card.historyEntry'),

  classNames: ['card-editor-editor'],

  saveCard: task(function*() {
    try {
      let r = yield this.get('card').save();
      yield r.reload();
      this.set('errors', []);
    } catch (e) {
      this.set('errors', e.errors);
    }
  }),

  publishCard: task(function*() {
    let card = this.get('card');
    try {
      yield card.publish();
      yield card.reload();
      this.set('showPublishOverlay', false);
      this.set('errors', []);
    } catch (e) {
      this.set('errors', e.errors);
    }
  }),

  revertCard: task(function*() {
    let card = this.get('card');
    try {
      yield card.revert();
      yield card.reload();
      this.set('showRevertOverlay', false);
      this.set('errors', []);
    } catch (e) {
      this.set('errors', e.errors);
    }
  }),

  archiveCard: task(function*() {
    let card = this.get('card');

    try {
      yield card.archive();
      this.set('errors', []);
      let journalID = yield card.get('journal.id');
      this.get('routing').transitionTo('admin.journals.cards', [journalID]);
    } catch (e) {
      this.set('errors', e.errors);
    }
  }),

  deleteCard: task(function*() {
    let card = this.get('card');

    try {
      let journalID = yield card.get('journal.id');
      yield card.destroyRecord();
      this.set('errors', []);
      this.get('routing').transitionTo('admin.journals.cards', [journalID]);
    } catch (e) {
      this.set('errors', e.errors);
    }
  }),

  actions: {
    updateXML(code) {
      this.set('card.xml', code);
    },

    confirmPublish() {
      this.set('showPublishOverlay', true);
    },

    confirmArchive() {
      this.set('showArchiveOverlay', true);
    },

    confirmDelete() {
      this.set('showDeleteOverlay', true);
    },

    confirmRevert() {
      this.set('showRevertOverlay', true);
    }
  }
});
