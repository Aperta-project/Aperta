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
import { test, moduleForComponent } from 'ember-qunit';

let board;

moduleForComponent('comment-board', 'Unit: components/comment-board', {
  unit: true,

  beforeEach: function() {
    let comments = [1,2,3,4,5,6,7,8].map((number)=> {
      return Ember.Object.create({
        body: 'comment ' + number,
        createdAt: number
      });
    });

    Ember.run(this, function() {
      board = this.subject();
      board.set('comments', comments);
    });
  }
});

test('#firstComments returns the latest 5 comments in reverse order', function(assert) {
  let expectedCommentBodies = board.get('firstComments').map(function(comment) {
    return comment.get('body');
  });

  assert.deepEqual(
    expectedCommentBodies,
    ["comment 8", "comment 7", "comment 6", "comment 5", "comment 4"]
  );
});

test('#showingAllComments returns false if there are more than 5 comments', function(assert) {
  assert.ok(!board.get('showingAllComments'));
});
