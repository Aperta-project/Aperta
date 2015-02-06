`import Ember from 'ember'`
`import { test, moduleForComponent } from 'ember-qunit'`

moduleForComponent 'comment-board', 'Unit: components/comment-board',
  setup: ->
    @comment1 = Ember.Object.create body: "comment 1", createdAt: 1
    @comment2 = Ember.Object.create body: "comment 2", createdAt: 2
    @comment3 = Ember.Object.create body: "comment 3", createdAt: 3
    @comment4 = Ember.Object.create body: "comment 4", createdAt: 4
    @comment5 = Ember.Object.create body: "comment 5", createdAt: 5
    @comment6 = Ember.Object.create body: "comment 6", createdAt: 6
    @comment7 = Ember.Object.create body: "comment 7", createdAt: 7
    @comment8 = Ember.Object.create body: "comment 8", createdAt: 8

    Ember.run =>
      @board = @subject()
      @board.set('comments', [@comment1, @comment2, @comment3, @comment4, @comment5, @comment6, @comment7, @comment8])

test '#firstComments returns the latest 5 comments in reverse order', ->
  expectedCommentBodies = @board.get('firstComments').map (comment) -> comment.get('body')
  deepEqual expectedCommentBodies, [ "comment 8", "comment 7", "comment 6", "comment 5", "comment 4" ]

test '#showingAllComments returns false if there are more than 5 comments', ->
  ok !@board.get('showingAllComments')

test '#showAllComments action should set @showingAllComments to true', ->
  @board.send 'showAllComments'
  ok @board.get('showingAllComments')
