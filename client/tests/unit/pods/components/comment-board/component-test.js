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
