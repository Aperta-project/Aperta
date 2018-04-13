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
    journal: PropTypes.EmberObject,
    success: PropTypes.func, // action, called when card is created
    close: PropTypes.func // action, called to close the overlay
  },

  classNames: ['admin-overlay'],
  store: Ember.inject.service(),
  cardName: '',
  cardTaskType: null,
  cardTaskTypes: Ember.computed.reads('journal.cardTaskTypes'),
  saving: Ember.computed.reads('createCard.isRunning'),
  errors: null,

  init() {
    this._super(...arguments);
    this.get('cardTaskTypes').then((ctts) => {
      this.set('cardTaskType', ctts.findBy('taskClass', 'CustomCardTask'));
    });
  },


  createCard: task(function * () {
    this.set('errors', null);
    const card = this.get('store').createRecord('card', {
      name: this.get('cardName'),
      cardTaskType: this.get('cardTaskType'),
      journal: this.get('journal')
    });

    try {
      yield card.save();
      this.get('success')(card);
      this.get('close')();
    } catch (e) {
      this.set('errors', card.get('errors'));
    }
  }),

  didReceiveAttrs(){
    //Defaults the dropdown as the first element in the card list
    this.set('cardTaskType', this.get('cardTaskTypes')[0]);
  },

  actions: {
    close() {
      this.get('close')();
    },

    complete() {
      this.get('createCard').perform();
    },

    valueChanged(newVal) {
      this.set('cardTaskType', newVal);
    }
  }
});
