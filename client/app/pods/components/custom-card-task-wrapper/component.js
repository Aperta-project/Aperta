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
let { any, bool, func, oneOfType } = PropTypes;

export default Ember.Component.extend({
  propTypes: {
    contentRoot: any.isRequired,
    disabled: bool.isRequired,
    hideCompletedSection: bool,
    owner: any.isRequired,
    preview: bool.isRequired,
    scenario: any.isRequired,
    task: any.isRequired,
    taskStateToggleable: bool.isRequired,
    toggleTaskCompletion: func.isRequired,
    validationErrors: any.isRequired,
    repetition: oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired
  },

  getDefaultProps() {
    return {
      hideCompletedSection: false
    };
  },

  actions: {
    toggleTaskCompletion() {
      this.get('toggleTaskCompletion')();
    }
  }
});
