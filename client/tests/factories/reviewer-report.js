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

FactoryGuy.define('reviewer-report', {
  default: {
    task: { id: 1 },
    decision: { id: 1},
    dueDatetime: FactoryGuy.belongsTo('due-datetime'),
    dueAt: '2017-07-04T14:00:00.028Z',
    originallyDueAt: '2017-07-04T14:00:00.028Z',
    user: { id: 1}
  },
  traits: {
    with_questions: {
      nestedQuestions(report) {
        return [
          'reviewer_report--additional_comments',
          'reviewer_report--comments_for_author',
          'reviewer_report--competing_interests',
          'reviewer_report--competing_interests--detail',
          'reviewer_report--decision_term',
          'reviewer_report--identity',
          'reviewer_report--suitable_for_another_journal',
          'reviewer_report--suitable_for_another_journal--journal',
          'reviewer_report--attachments'
        ].map(function(ident) {
          return FactoryGuy.make('nested-question', {owner: report, ident });
        });
      }
    },
    with_front_matter_questions: {
      nestedQuestions(report) {
        return [
          'front_matter_reviewer_report--additional_comments',
          'front_matter_reviewer_report--competing_interests',
          'front_matter_reviewer_report--decision_term',
          'front_matter_reviewer_report--identity',
          'front_matter_reviewer_report--includes_unpublished_data',
          'front_matter_reviewer_report--includes_unpublished_data--explanation',
          'front_matter_reviewer_report--suitable',
          'front_matter_reviewer_report--suitable--comment',
          'front_matter_reviewer_report--attachments'
        ].map(function(ident) {
          return FactoryGuy.make('nested-question', {owner: report, ident });
        });
      }
    }
  }
});
