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
import QAIdent from 'tahi/mixins/components/qa-ident';

export default Ember.Component.extend(QAIdent, {
  classNames: ['card-content', 'card-content-export-paper'],
  owner: null, //owner
  content: null, //card content
  disabled: false,
  store: Ember.inject.service(),
  task: Ember.computed.reads('owner'),
  destination: Ember.computed.reads('content.text'),
  createExportDelivery: task(function * () {
    if (this.get('disabled')) {
      return;
    }
    const exportDelivery = this.get('store').createRecord('export-delivery', {
      task: this.get('task'),
      destination: this.get('destination')
    });

    try {
      yield exportDelivery.save();
      this.get('success')(exportDelivery);
    } catch (e) {
      this.set('errors', exportDelivery.get('errors'));
    }
  }),
  actions: {
    sendToApex() {
      this.get('createExportDelivery').perform();
    }
  }
});
