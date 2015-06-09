`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'controller:overlays/cover-letter', 'CoverLetterController',
  needs: ['controller:application']

  setup: ->
    startApp()

    @task = Ember.Object.create
      isSubmissionTask: true
      paper: @paper
      body: ['']
      save: ->

    Ember.run =>
      @ctrl = @subject()
      @ctrl.set('model', @task)

test '#letterBody: returns the content of the cover letter', ->
  equal @ctrl.get('letterBody'), ''

test '#formatCoverLetter: replaces newline with p tag', ->
  @ctrl.set('letterBody', "foo\nbar")
  result = @ctrl.get('formatCoverLetter')
  equal result, '<p>foo</p><p>bar</p>'

test "#editingLetter: returns false when the paper has cover letter", ->
  ok !@ctrl.get('editingLetter')

test "#editingLetter: returns true when the paper doesn't have cover letter", ->
  @task.body = []
  @ctrl.set('model', @task)

  ok @ctrl.get 'editingLetter'

test "#editCoverLetter: toggle the state of the cover letter from preview to edit", ->
  @ctrl.set('editingLetter', false)
  @ctrl.send('editCoverLetter')

  ok @ctrl.get 'editingLetter'

test '#saveCoverLetter', ->
  handler = ()->

  sinon.stub(@task, 'save').returns(new Ember.RSVP.Promise(handler, handler))
  Ember.run =>
    @ctrl.send('saveCoverLetter')
    ok @task.save.called
