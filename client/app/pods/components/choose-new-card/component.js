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
import {PropTypes} from 'ember-prop-types';

const { computed, on } = Ember;

export default Ember.Component.extend(EscapeListenerMixin, {
  propTypes: {
    phase: PropTypes.EmberObject,
    journalTaskTypes: PropTypes.oneOfType([PropTypes.array, PropTypes.EmberObject]), // Could also be a DS.ManyArray or DS.PromiseManyArray object
    cards: PropTypes.oneOfType([PropTypes.array, PropTypes.EmberObject]),
    onSave: PropTypes.func,
    isLoading: PropTypes.bool,
    close: PropTypes.func
  },

  setuptaskTypeList: on('init', function() {
    if (!this.get('selectedCards')) {
      this.set('selectedCards', []);
    }
  }),

  // card-config
  cardSort: ['name:asc'],
  publishedCards: computed.filterBy('cards', 'state', 'published'),
  sortedCards: computed.sort('publishedCards', 'cardSort'),
  addableCards: computed.filterBy('sortedCards', 'addable', true),
  addableWorkFlowCards: computed.filterBy('sortedCards', 'workflow_only', true),
  addableNonWorkFlowCards: computed.setDiff('sortedCards', 'addableWorkFlowCards'),

  // pre-card-config
  taskTypeSort: ['title:asc'],

  // TODO: get rid of task type filtering after last legacy card ruby class is deleted
  filteredTaskTypes: computed.filter('journalTaskTypes', function(taskType) {
    let title = taskType.get ? taskType.get('title') : '';
    return title !== 'SUBCLASSME' && title !== 'Custom Card';
  }),

  authorTasks: computed.filterBy('filteredTaskTypes', 'roleHint', 'author'),
  unsortedAuthorColumn: computed.union('authorTasks', 'addableNonWorkFlowCards'),
  authorColumn: computed.sort('unsortedAuthorColumn', 'taskTypeSort'),

  staffTasks: computed.setDiff('filteredTaskTypes', 'authorTasks'),
  unsortedStaffColumn: computed.union('staffTasks', 'addableWorkFlowCards'),
  staffColumn: computed.sort('unsortedStaffColumn', 'taskTypeSort'),

  save() {
    this.get('onSave')(
      this.get('phase'),
      this.get('selectedCards')
    );
    this.get('close')();
  },

  actions: {
    updateList(checkbox) {
      if (checkbox.get('checked')) {
        this.get('selectedCards').pushObject(checkbox.get('task'));
      } else {
        this.get('selectedCards').removeObject(checkbox.get('task'));
      }
    },

    throttledSave() {
      Ember.run.throttle(this, this.get('save'), 500);
    },

    close() {
      this.get('close')();
    }
  }
});
