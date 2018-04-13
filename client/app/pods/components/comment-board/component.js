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
const { computed } = Ember;

export default Ember.Component.extend({
  classNames: ['comment-board'],
  comments: [],
  commentsToShow: 5,
  commentSort: ['createdAt:desc'],
  sortedComments: computed.sort('comments', 'commentSort'),

  firstComments: computed('sortedComments', function() {
    return this.get('sortedComments').slice(0, 5);
  }),

  showingAllComments: computed('comments.length', function() {
    return this.get('comments.length') <= this.get('commentsToShow');
  }),

  omittedCommentsCount: computed('comments.length', function() {
    return this.get('comments.length') - this.get('commentsToShow');
  }),

  actions: {
    showAllComments() {
      this.set('showingAllComments', true);
    },

    postComment(text) {
      if(Ember.isEmpty(text)) { return; }
      this.attrs.postComment(text);
    }
  }
});
