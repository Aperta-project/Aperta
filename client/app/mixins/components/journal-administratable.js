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
import RSVP from 'rsvp';
import DS from 'ember-data';

export default Ember.Mixin.create({
  can: Ember.inject.service(),

  canAdminJournal: Ember.computed.alias('canAdminJournalPromise.content'),

  canAdminJournalPromise: Ember.computed('journal', function() {
    let journal = this.get('journal');

    if (journal) {
      let permission = this.get('can').can('administer', journal);
      return this._wrapInPromiseObject(permission);
    } else {

      let promiseArray = this.get('journals').map((journal) => {
        return this.get('can').can('administer', journal);
      });

      let returnPromise = RSVP.Promise.all(promiseArray).then((values) => {
        return values.every((value) => { return value === true; });
      });

      return this._wrapInPromiseObject(returnPromise);
    }
  }),

  // canAdminJournal() needs to return a promise based on its reliance on a set of
  // of `can` permissions which each make an ajax request. Wrapping that promise
  // in this DS.PromiseObject allows the ember computed to compute properly  off
  // of the the content property of the PromiseObject as seen in canAdminJournal()
  // More info at: https://www.emberjs.com/api/ember-data/2.14/classes/DS.PromiseObject
  _wrapInPromiseObject(value) {
    return DS.PromiseObject.create({promise: value});
  }
});
