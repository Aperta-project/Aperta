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
import DS from 'ember-data';

export default DS.Model.extend({
  ident: DS.attr('string'),
  position: DS.attr('number'),
  value_type: DS.attr('string'),
  createdAt: DS.attr('date'),
  updatedAt: DS.attr('date'),
  additionalData: DS.attr('string'), //additionalData is provided so templates
                                     //have a way to carry out actions based on
                                     //a question's answer.  Like populate a
                                     //textbox with boilerplate text if it is
                                     //checked or not.

  text: DS.attr('string'),
  children: DS.hasMany('nested-question', { async: false, inverse: 'parent' }),
  parent: DS.belongsTo('nested-question', { async: false, inverse: 'children' }),
  answers: DS.hasMany('nested-question-answer', {
    async: false , inverse: 'nestedQuestion'
  }),

  answerForOwner(owner){
    let ownerId = owner.get('id');
    let answer = this.get('answers').toArray().find(function(answer){
      let answerOwnerId = answer.get('owner.id') || answer.get('data.owner.id');
      let matched = Ember.isEqual(parseInt(answerOwnerId), parseInt(ownerId));

      matched = matched && !answer.get('isDeleted');
      return matched;
    });

    if(!answer){
      answer = this.store.createRecord('nested-question-answer', {
        nestedQuestion: this,
        owner: owner,
      });
    }

    return answer;
  },

  clearAnswerForOwner(owner){
    const answer = this.answerForOwner(owner);
    if(answer){
      answer.rollbackAttributes();
    }
  }
});
