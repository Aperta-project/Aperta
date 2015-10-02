`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`

moduleFor 'controller:overlays/ad-hoc', 'AdHocOverlayController',
  needs: ['controller:application', 'controller:paper/task']

  beforeEach: ->
    @task = Ember.Object.create
      id: 99

    Ember.run =>
      @ctrl = @subject()
      @ctrl.set('model', @task)

test 'imageUploadUrl updates when model is changed', (assert)->
  assert.equal "/api/tasks/99/attachments", @ctrl.get('imageUploadUrl')
  Ember.run =>
    @ctrl.set('model.id', 111)
  assert.equal "/api/tasks/111/attachments", @ctrl.get('imageUploadUrl')
