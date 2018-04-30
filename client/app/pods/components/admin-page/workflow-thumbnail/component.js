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
  workflow: {},
  workflows: [],
  classNames: [],
  confirmDestroy: false,
  canDestroy: Ember.computed('workflow', 'workflows.[]', function() {
    let journal_id = this.get('workflow.journal.id');
    return this.get('workflows').filterBy('journal.id', journal_id).length > 1;
  }),

  actions: {
    toggleConfirmDestroy() {
      this.toggleProperty('confirmDestroy');
    },
    hideConfirmDestroy() {
      this.set('confirmDestroy', false);
    },
    destroyWorkflow() {
      if (this.get('canDestroy')) {
        this.get('workflow').deleteRecord();
        this.get('workflow').save();
      }
    },
    doNothing(){
      // prevent action of underlying element with bubbles=false
    }
  }
});
