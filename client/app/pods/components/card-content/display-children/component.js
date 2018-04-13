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
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  classNames: ['card-content', 'card-content-display-children'],
  classNameBindings: ['customDisplayClass'],
  tagName: '',
  enabled: true,

  init() {
    this._super(...arguments);
    let customClass = this.get('customClass');
    let defaultTag = customClass ? 'div' : '';
    this.set('tagName', this.getWithDefault('wrapperTag', defaultTag));
    if (Ember.isEmpty(this.get('tagName'))) {
      // We can't have classNameBindings on tagless view wrappers
      this.set('classNameBindings', []);
    }
  },

  // see https://github.com/emberjs/ember.js/pull/14389
  customDisplayClass: Ember.computed('customClass', {
    get() {
      if (this.get('customClass')) {
        return `${this.get('customClass')}`;
      } else {
        return null;
      }
    }
  }),

  customChildClass: Ember.computed.readOnly('content.customChildClass'),
  childTag: Ember.computed.readOnly('content.childTag'),
  customClass: Ember.computed.readOnly('content.customClass'),
  wrapperTag: Ember.computed.readOnly('content.wrapperTag'),

  propTypes: {
    childTag: PropTypes.oneOf(['li', null]),
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired,
    preview: PropTypes.bool
  }
});
