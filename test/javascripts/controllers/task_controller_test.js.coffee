#= require test_helper

moduleFor 'controller:task', 'TaskController',
  needs: ['controller:application']
  setup: ->
    @litePaper = Ember.Object.create
      submitted: true

    ETahi.currentUser = Ember.Object.create
      user:
        admin: false

    @task = Ember.Object.create
      isMetadataTask: true
      litePaper: @litePaper

    Ember.run =>
      @subject().set('model', @task)


test '#isEditable: true when the task is not a metadata task', ->
  equal @subject().get('isEditable'), true

test '#isEditable: always true when the user is an admin', ->
  ETahi.currentUser.user.admin = true
  equal @subject().get('isEditable'), true

test '#isEditable: true when paper is not submitted and task is a metadata task', ->
  @litePaper.set('submitted', false)

  equal @subject().get('isEditable'), true

test '#isEditable: false when the paper is submitted and the task is a metadata task', ->
  Ember.run =>
    @litePaper.set('submitted', true)
    @task.set('isMetadataTask', true)
    equal @subject().get('isEditable'), false

