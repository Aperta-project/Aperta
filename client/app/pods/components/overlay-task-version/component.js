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
  /**
   *  Method called after out animation is complete.
   *  This should be set to an action.
   *  This method is passed to `overlay-animate`
   *
   *  @method outAnimationComplete
   *  @required
  **/
  outAnimationComplete: null,

  selectedSnapshots: task(function * () {
    yield this.fetchSnapshots();
    const apertaTask = this.get('model');
    return {
      v1: apertaTask.getSnapshotForVersion(this.get('selectedVersion1')),
      v2: apertaTask.getSnapshotForVersion(this.get('selectedVersion2'))
    };
  }),

  init() {
    this._super(...arguments);
    this._assertions();
  },

  fetchSnapshots() {
    return this.get('model').get('snapshots');
  },

  _assertions() {
    Ember.assert(
      `You must provide an outAnimationComplete
       action to OverlayTaskVersionComponent`,
      !Ember.isEmpty(this.get('outAnimationComplete'))
    );

    Ember.assert(
      `You must provide a model
       action to OverlayTaskVersionComponent`,
      !Ember.isEmpty(this.get('model'))
    );
  },

  actions: {
    close() {
      this.attrs.outAnimationComplete();
    }
  }
});
