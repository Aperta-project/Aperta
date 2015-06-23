`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'controller:paper/task', 'TaskController',
  needs: ['controller:application']
  beforeEach: ->
    @paper = Ember.Object.create
      editable: true

    @currentUser = Ember.Object.create
      siteAdmin: false

    currentUser = @currentUser
    @task = Ember.Object.create
      isSubmissionTask: true
      paper: @paper

    Ember.run =>
      @subject().set('model', @task)
      @subject().set('controllers.application.currentUser', currentUser)

test '#isEditable: true when the task is not a metadata task', ->
  Ember.run =>
    @task.set('isSubmissionTask', false)
    equal @subject().get('isEditable'), true

test '#isEditable: always true when the user is an admin', ->
  Ember.run =>
    @currentUser.set('siteAdmin', true)
    @task.set('isSubmissionTask', true)
    @paper.set('editable', false)
    equal @subject().get('isEditable'), true

test '#isEditable: true when paper is editable and task is a metadata task', ->
  Ember.run =>
    @paper.set('editable', true)
    equal @subject().get('isEditable'), true

test '#isEditable: false when the paper is not editable and the task is a metadata task', ->
  Ember.run =>
    @paper.set('editable', false)
    @task.set('isSubmissionTask', true)
    equal @subject().get('isEditable'), false
