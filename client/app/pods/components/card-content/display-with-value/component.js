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
  tagName: '',

  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    owner: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired,
    preview: PropTypes.bool
  },

  parentAnswer: Ember.computed('content.parent', 'owner', 'repetition', function() {
    return this.get('content.parent').answerForOwner(this.get('owner'), this.get('repetition'));
  }),

  showChildren: Ember.computed(
    'parentAnswer.value',
    'content.visibleWithParentAnswer',
    function() {
      let parentValue = this.get('parentAnswer.value');
      if (parentValue === null || parentValue === undefined) { return false; }
      return (parentValue).toString() ===
        this.get('content.visibleWithParentAnswer');
    }
  ),

  pruneOldAnswers: Ember.observer('showChildren', function() {
    if(this.get('preview')) { return; }
    if(this.get('showChildren')) { return; }

    let owner = this.get('owner');
    let content = this.get('content');
    let repetition = this.get('repetition');

    content.destroyDescendants(owner, repetition);
  }),
});
