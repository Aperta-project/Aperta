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

import NestedQuestionOwner from 'tahi/pods/nested-question-owner/model';
import Answerable from 'tahi/mixins/answerable';
import DS from 'ember-data';

let a = DS.attr;

export default NestedQuestionOwner.extend(Answerable, {
  firstName: a('string'),
  middleInitial: a('string'),
  lastName: a('string'),
  email: a('string'),
  title: a('string'),
  department: a('string'),
  affiliation: a('string'),
  ringgoldId: a('string'),
  recommendOrOppose: a('string'),
  reason: a('string'),
  reviewerRecommendationsTask: DS.belongsTo('reviewerRecommendationsTask'),

  fullName: function() {
    return [this.get('firstName'), this.get('middleInitial'), this.get('lastName')].compact().join(' ');
  }.property('firstName', 'middleInitial', 'lastName'),

});
