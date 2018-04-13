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

import FactoryGuy from 'ember-data-factory-guy';
import Ember from 'ember';

FactoryGuy.define('nested-question', {
  default: {
    value_type: 'text',
    text: '',
    owner: null,
    answers: []
  },

  traits: {}
});

export function createQuestionWithAnswer(owner, identOrAttrs, answerValue){
  let answers = [];

  if(answerValue){
    let answer = FactoryGuy.make('nested-question-answer', {
      value: answerValue,
      owner: owner
    });
    answers.push(answer);
  }

  let ident;
  let questionAttrs;
  if (_.isObject(identOrAttrs)) {
    ident = identOrAttrs.ident;
    questionAttrs = identOrAttrs;
  } else {
    ident = identOrAttrs;
    questionAttrs = {ident: ident};
  }

  let question = owner.get('nestedQuestions').findBy('ident', ident);
  Ember.run(() => {
    if(!question){
      question = FactoryGuy.make('nested-question', questionAttrs);
      owner.get('nestedQuestions').addObject(question);
    }

    question.set('answers', answers);
  });
  return question;
}

export function createQuestion(owner, ident, text){
  let questionText = (text || `This is the question text for ${ident}`);

  let question = owner.get('nestedQuestions').findBy('ident', ident);
  Ember.run(() => {
    if(!question) {
      question = FactoryGuy.make('nested-question', {ident: ident, owner: owner, text: text});
      owner.get('nestedQuestions').addObject(question);
    }

    question.set('text', questionText);

    owner.get('nestedQuestions').addObject(question);
  });
  return question;
}
