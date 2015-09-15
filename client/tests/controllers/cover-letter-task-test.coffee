`import Ember from 'ember'`
`import startApp from '../helpers/start-app'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'controller:overlays/cover-letter', 'CoverLetterController',
  needs: ['controller:application']

  beforeEach: ->
    startApp()

    @task = Ember.Object.create
      isSubmissionTask: true
      paper: @paper
      body: ['']
      save: ->
        then: (fn) ->
          fn.call()

    Ember.run =>
      @ctrl = @subject()
      @ctrl.set('model', @task)

test '#letterBody: returns the content of the cover letter', (assert) ->
  assert.equal @ctrl.get('letterBody'), ''

test "#editingLetter: returns false when the paper has cover letter", (assert) ->
  assert.ok !@ctrl.get('editingLetter')

test "#editingLetter: returns true when the paper doesn't have cover letter", (assert) ->
  @task.body = []
  @ctrl.set('model', @task)

  assert.ok @ctrl.get 'editingLetter'

test "#editCoverLetter: toggle the state of the cover letter from preview to edit", (assert) ->
  @ctrl.set('editingLetter', false)
  @ctrl.send('editCoverLetter')

  assert.ok @ctrl.get 'editingLetter'

test '#saveCoverLetter: model got saved back', (assert) ->
  handler = ()->

  sinon.stub(@task, 'save').returns(new Ember.RSVP.Promise(handler, handler))
  @ctrl.send('saveCoverLetter')
  assert.ok @task.save.called

test '#saveCoverLetter: toggle editCoverLetter to be false', (assert) ->
  @ctrl.set('model.editingLetter', true)
  @ctrl.send('saveCoverLetter')

  assert.equal @ctrl.get('editingLetter'), false
