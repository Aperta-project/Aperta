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
import resizeColumnHeaders from 'tahi/lib/resize-column-headers';

export default Ember.Component.extend({
  classNames: ['column-header'],
  classNameBindings: ['active'],

  active: false,
  previousContent: null,

  currentHeaderHeight: Ember.computed('phase.name', function() {
    return this.$().find('.column-title').height();
  }),

  focusIn(e) {
    this.set('active', true);
    if ($(e.target).attr('contentEditable')) {
      this.set('oldPhaseName', this.get('phase.name'));
    }
  },

  input() {
    if (this.get('currentHeaderHeight') <= 58) {
      return this.set('previousContent', this.get('phase.name'));
    } else {
      return this.set('phase.name', this.get('previousContent'));
    }
  },

  phaseNameDidChange: Ember.observer('phase.name', function() {
    return Ember.run.scheduleOnce('afterRender', this, resizeColumnHeaders);
  }),

  actions: {
    save() {
      this.set('active', false);
      this.sendAction('savePhase', this.get('phase'));
    },

    remove() {
      this.sendAction('removePhase', this.get('phase'));
    },

    cancel() {
      this.set('active', false);
      this.sendAction('rollbackPhase', this.get('phase'), this.get('oldPhaseName'));
      Ember.run.scheduleOnce('afterRender', this, resizeColumnHeaders);
    }
  }
});
