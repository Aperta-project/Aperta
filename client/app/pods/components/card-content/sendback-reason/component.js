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
import QAIdent from 'tahi/mixins/components/qa-ident';

let childAt = function(key, position) {
  return Ember.computed(`${key}.[]`, function() {
    return this.get(key).objectAt(position);
  });
};


export default Ember.Component.extend(QAIdent, {

  propTypes: {
    answer: PropTypes.EmberObject.isRequired,
    content: PropTypes.EmberObject.isRequired,
    owner: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired,
    answerChanged: PropTypes.any.isRequired
  },

  classNames: ['card-content', 'card-content-sendback-reason'],

  shouldHide: Ember.observer('checkboxAnswer.value', function() {
    Ember.run.once(this, 'revertChildrenAnswers');
  }),

  hasText: Ember.computed.notEmpty('content.text'),

  revertChildrenAnswers() {
    if (!this.get('checkboxAnswer.value')) {
      this.get('textareaAnswer').set('value', this.get('textarea.defaultAnswerValue'));
    }
  },

  checkboxAnswer: Ember.computed('checkbox', 'owner', 'repetition', function(){
    return this.get('checkbox').answerForOwner(this.get('owner'), this.get('repetition'));
  }),

  pencilAnswer: Ember.computed('pencil', 'owner', 'repetition', function(){
    return this.get('pencil').answerForOwner(this.get('owner'), this.get('repetition'));
  }),

  textareaAnswer: Ember.computed('textarea', 'owner', 'repetition', function(){
    return this.get('textarea').answerForOwner(this.get('owner'), this.get('repetition'));
  }),

  checkbox: childAt('content.children', 0),
  pencil: childAt('content.children', 1),
  textarea: childAt('content.children', 2),
  showText: Ember.computed(
    'checkboxAnswer.value',
    'pencilAnswer.value',
    function() {
      return this.get('checkboxAnswer.value') && this.get('pencilAnswer.value');
    }
  ),
  actions: {
    toggleAnswer(answer) {
      answer.toggleProperty('value');
      if (this.get('preview')) {return Ember.RSVP.resolve();}
      return answer.save();
    }
  }

});
