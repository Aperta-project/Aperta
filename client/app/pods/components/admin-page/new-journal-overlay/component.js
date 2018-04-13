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
import { PropTypes } from 'ember-prop-types';
import { task } from 'ember-concurrency';

export default Ember.Component.extend(EscapeListenerMixin, {
  propTypes: {
    success: PropTypes.func, // action, called when journal is created
    close: PropTypes.func // action, called to close the overlay
  },

  store: Ember.inject.service(),
  routing: Ember.inject.service('-routing'),
  classNames: ['admin-new-journal-overlay'],
  saving: Ember.computed.reads('createJournal.isRunning'),
  errors: null,

  name: '',
  description: '',
  doiJournalPrefix: '',
  doiPublisherPrefix: '',
  lastDoiIssued: '',
  logoUrl: '',

  clearErrors() {
    this.set('errors', null);
  },

  redirectToJournal(journal) {
    this.get('routing').transitionTo('admin.journals', [journal.id]);
  },

  createJournal: task(function * () {
    let newJournalProps = this.getProperties([
      'name',
      'description',
      'doiPublisherPrefix',
      'doiJournalPrefix',
      'lastDoiIssued',
      'logoUrl'
    ]);
    const journal = this.get('store').createRecord('admin-journal', newJournalProps);

    try {
      yield journal.save();
      this.get('success')(journal);
      this.redirectToJournal(journal);
      this.get('close')();
    } catch (response) {
      this.set('errors', journal.get('errors'));
    }
  }),

  actions: {
    close() {
      this.get('close')();
      this.clearErrors();
    },

    complete() {
      this.get('createJournal').perform();
    }
  }
});
