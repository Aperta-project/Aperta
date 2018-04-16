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
  classNames: ['column'],

  //attrs passed in
  phaseTemplate: null,

  //actions passed in
  addPhase: null,
  savePhase: null,
  removeRecord: null,
  rollbackPhase: null,
  showDeleteConfirm: null,
  showSettings: null,
  chooseNewCardTypeOverlay: null,

  nextPosition: Ember.computed('phaseTemplate.position', function() {
    return this.get('phaseTemplate.position') + 1;
  }),

  sortedTasks: Ember.computed('phaseTemplate.taskTemplates.[]', function() {
    return this.get('phaseTemplate.taskTemplates').sortBy('position');
  }),

  actions: {
    chooseNewCardTypeOverlay(phase) {
      this.sendAction('chooseNewCardTypeOverlay', phase);
    },

    savePhase(phase) {
      this.sendAction('savePhase', phase);
    },

    addPhase(position)          {
      this.sendAction('addPhase', position);
    },

    removeRecord(phase) {
      this.sendAction('removeRecord', phase);
    },

    rollbackPhase(phase)  {
      this.sendAction('rollbackPhase', phase);
    },

    showDeleteConfirm(task) {
      this.sendAction('showDeleteConfirm', task);
    },

    showSettings(task) {
      this.sendAction('showSettings', task);
    }
  }
});
