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
import { task } from 'ember-concurrency';

export default Ember.Component.extend({
  card: null,
  classNames: ['card-editor-name-container'],
  cardName: Ember.computed.alias('card.name'),

  editing: false,
  saving: Ember.computed.reads('saveCard.isRunning'),
  errors: null,

  saveCard: task(function * () {
    const card = this.get('card');
    this.clearErrors();

    card.set('name', this.get('cardName'));

    try {
      yield card.save();
      this.set('editing', false);
    } catch (e) {
      this.set('errors', card.get('errors'));
    }
  }),

  clearErrors() {
    this.set('errors', null);
  },

  actions: {
    edit() {
      this.set('editing', true);
    },

    cancel() {
      this.set('editing', false);
      this.get('card').rollbackAttributes();
      this.clearErrors();
    },

    complete() {
      this.get('saveCard').perform();
    }
  }
});
