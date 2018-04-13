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

export default Ember.Component.extend(QAIdent, {
  classNames: ['card-content', 'card-content-tech-check'],
  propTypes: {
    content: PropTypes.EmberObject.isRequired,
    disabled: PropTypes.bool,
    answer: PropTypes.EmberObject.isRequired,
    repetition: PropTypes.oneOfType([PropTypes.null, PropTypes.EmberObject]).isRequired,
    preview: PropTypes.bool
  },

  clearSendbacks() {
    let sendbackAnswers = this.get('content.children').map(sendbackContent => {
      let checkbox = sendbackContent.get('children.firstObject');
      return checkbox.answerForOwner(this.get('owner'), this.get('repetition'));
    });

    sendbackAnswers.setEach('value', false);
    if (!this.get('preview')) {
      sendbackAnswers.invoke('save');
    }
  },
  actions: {
    sendbackChanged(sendbackAnswer) {
      let techCheckAnswer = this.get('answer');
      if (sendbackAnswer.get('value') === true) {
        techCheckAnswer.set('value', false);
        let action = this.get('valueChanged');
        if (action) {
          action(false);
        }
      }
    },
    saveAnswer(newVal) {
      let action = this.get('valueChanged');
      if (action) {
        action(newVal);
      }

      if (newVal) {
        //if the check has 'passed' manually
        this.clearSendbacks();
      }
    }
  }
});
