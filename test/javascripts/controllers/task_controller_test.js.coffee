moduleFor 'controller:task', 'TaskController',
  needs: ['controller:application']
  tearDown: -> ETahi.reset()
  setup: ->
    setupApp()
    @litePaper = Ember.Object.create
      submitted: true

    @currentUser = Ember.Object.create
      admin: false

    currentUser = @currentUser
    @task = Ember.Object.create
      isMetadataTask: true
      litePaper: @litePaper

    Ember.run =>
      @subject().set('model', @task)
      @subject().set('controllers.application.currentUser', currentUser)

test '#isEditable: true when the task is not a metadata task', ->
  Ember.run =>
    @task.set('isMetadataTask', false)
    equal @subject().get('isEditable'), true

test '#isEditable: always true when the user is an admin', ->
  Ember.run =>
    @currentUser.set('admin', true)
    @task.set('isMetadataTask', true)
    @litePaper.set('submitted', true)
    equal @subject().get('isEditable'), true

test '#isEditable: true when paper is not submitted and task is a metadata task', ->
  Ember.run =>
    @litePaper.set('submitted', false)
    equal @subject().get('isEditable'), true

test '#isEditable: false when the paper is submitted and the task is a metadata task', ->
  Ember.run =>
    @litePaper.set('submitted', true)
    @task.set('isMetadataTask', true)
    equal @subject().get('isEditable'), false
