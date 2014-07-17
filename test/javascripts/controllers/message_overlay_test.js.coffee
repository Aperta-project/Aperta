moduleFor 'controller:messageOverlay', 'MessageOverlayController',
  needs: ['controller:application']
  tearDown: -> ETahi.reset()
  setup: ->
    setupApp()
    @comment1 = Ember.Object.create body: "comment 1", createdAt: 1
    @comment2 = Ember.Object.create body: "comment 2", createdAt: 2
    @comment3 = Ember.Object.create body: "comment 3", createdAt: 3
    @comment4 = Ember.Object.create body: "comment 4", createdAt: 4
    @comment5 = Ember.Object.create body: "comment 5", createdAt: 5
    @comment6 = Ember.Object.create body: "comment 6", createdAt: 6
    @comment7 = Ember.Object.create body: "comment 7", createdAt: 7
    @comment8 = Ember.Object.create body: "comment 8", createdAt: 8
    @message = Ember.Object.create
      title: "Test title"
      messageBody: "Test body"
      comments: [@comment1, @comment2, @comment3, @comment4, @comment5, @comment6, @comment7, @comment8]

    Ember.run =>
      @messageController = @subject()
      @messageController.set('model', @message)

test '#shownComments returns the latest 5 commets in reverse order', ->
  deepEqual @messageController.get('shownComments'), [ @comment4, @comment5, @comment6, @comment7, @comment8 ]

test '#showAllComments returns false if there are more than 5 comments', ->
  ok !@messageController.get('showAllComments')

test '#showAllComments action should set #shownComments to #sortedComments reversed and @showAllComments to true', ->
  ok !@messageController.get('showAllComments')
  deepEqual @messageController.get('shownComments'), [ @comment4, @comment5, @comment6, @comment7, @comment8 ]

  @messageController.send 'showAllComments'

  ok @messageController.get('showAllComments')
  deepEqual @messageController.get('shownComments'), [@comment1, @comment2, @comment3, @comment4, @comment5, @comment6, @comment7, @comment8]

