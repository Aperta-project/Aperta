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

const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['column'],
  phase: null,
  paper: null,

  nextPosition: computed('phase.position', function() {
    return this.get('phase.position') + 1;
  }),

  sortedTasks: computed('phase.tasks.[]', function() {
    return this.get('phase.tasks').sortBy('position');
  }),

  didInitAttrs() {
    this._super(...arguments);
    if(this.get('phase.isNew')) {
      Ember.run.scheduleOnce('afterRender', this, function() {
        this.animateIn();
      });
    }
  },

  animateIn() {
    const beginProps    = { overflow: 'hidden', opacity: 0, width: '0px' };
    const completeProps = { overflow: 'visible' };
    const el = this.$();
    const width = el.css('width');

    return $.Velocity.animate(this.$(), {
      opacity: 1,
      width: width
    }, {
      duration: 400,
      easing: [250, 20],
      begin:    function() { el.css(beginProps); },
      complete: function() { el.css(completeProps); }
    });
  },

  animateOut() {
    const el = this.$();

    return $.Velocity.animate(this.$(), {
      opacity: 0,
      width: '0px'
    }, {
      duration: 200,
      easing: [0.00, 0.00, 1.00, 0.02],
      begin: function() { el.css('overflow', 'hidden'); }
    });
  },

  actions: {
    chooseNewCardTypeOverlay(phase) {
      this.sendAction('chooseNewCardTypeOverlay', phase);
    },

    savePhase(phase)        { this.sendAction('savePhase', phase); },
    addPhase(position)      { this.sendAction('addPhase', position); },
    rollbackPhase(phase)    { this.sendAction('rollbackPhase', phase); },
    showDeleteConfirm(task) { this.sendAction('showDeleteConfirm', task); },

    removePhase(phase) {
      this.animateOut().then(()=> {
        this.sendAction('removePhase', phase);
      });
    }
  }
});
