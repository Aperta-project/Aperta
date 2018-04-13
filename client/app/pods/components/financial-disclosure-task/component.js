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

import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

const { computed, observer, on } = Ember;
const { alias } = computed;

export default TaskComponent.extend({
  funders: alias('task.funders'),
  paper: alias('task.paper'),
  receivedFunding: null,

  nestedQuestionsForNewFunder: Ember.A(),

  newFunderQuestions: on('init', function(){
    const queryParams = { type: 'Funder' };
    const results = this.get('store').query('nested-question', queryParams);

    results.then( (nestedQuestions) => {
      this.set('nestedQuestionsForNewFunder', nestedQuestions);
    });
  }),

  numFundersObserver: observer('funders.[]', function() {
    if (this.get('receivedFunding') === false) {
      return;
    }
    if (this.get('funders.length') > 0) {
      this.set('receivedFunding', true);
    } else {
      this.set('receivedFunding', null);
    }
  }),

  actions: {
    choseFundingReceived() {
      this.set('receivedFunding', true);
      if (this.get('funders.length') < 1) {
        return this.send('addFunder');
      }
    },

    choseFundingNotReceived() {
      this.set('receivedFunding', false);
      return this.get('funders').toArray().forEach(function(funder) {
        if (funder.get('isNew')) {
          return funder.deleteRecord();
        } else {
          return funder.destroyRecord();
        }
      });
    },

    addFunder() {
      return this.get('store').createRecord('funder', {
        nestedQuestions: this.get('nestedQuestionsForNewFunder'),
        task: this.get('task')
      }).save();
    }
  }
});
