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
  _throwDeprecationWarning: Ember.on('init', function() {
    Ember.deprecate(
      'TAHI DEPRECATION: ShowIfParent is deprecated.',
      false,
      { url: 'https://github.com/aperta-project/aperta/wiki/Tahi-Ember-1.13-Transition-Guide#showifparent-component' }
    );
  }),

  showContent: Ember.computed.reads('initialShowState'),

  initialShowState: Ember.computed('parentView', function() {
    return this.get(this.get('propName'));
  }),

  prop: '',

  propName: Ember.computed('prop', function() {
    return 'parentView.' + this.get('prop');
  }),

  showPropDidChange(sender, key) {
    this.set('showContent', sender.get(key));
  },

  setupObserver: Ember.on('didInsertElement', function() {
    this.addObserver(this.get('propName'), this, this.showPropDidChange);
  }),

  removeObserver: Ember.on('willDestroyElement', function() {
    Ember.removeObserver(this, this.get('propName'), this, this.showPropDidChange);
  })
});
