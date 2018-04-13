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
  tagName: "span",
  owner: null,
  ident: null,

  yesLabel: null,
  noLabel: null,

  answer: Ember.computed(function(){
    let owner = this.get("owner");
    Ember.assert("Must provide owner", owner);

    let ident = this.get("ident");
    Ember.assert("Must provide ident", ident);

    let answer = owner.answerForQuestion(ident);
    if(answer){
      return answer;
    } else {
      return null;
    }
  }),

  answerText: Ember.computed("answer", function(){
    let answer = this.get("answer");
    let yesLabel = this.get("yesLabel");
    let noLabel = this.get("noLabel");

    if(answer){
      let value = answer.get("value");
      if(yesLabel && value){
        return yesLabel;
      } else if(noLabel && !value){
        return noLabel;
      } else {
        return value;
      }
    } else {
      return "";
    }
  })
});
