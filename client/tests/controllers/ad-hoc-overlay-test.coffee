`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`
`import RESTless from 'tahi/services/rest-less'`

moduleFor 'controller:overlays/ad-hoc', 'AdHocOverlayController',
  needs: ['controller:application', 'controller:paper/task']

  beforeEach: ->
    sinon.stub(RESTless, 'putModel')

    @task = Ember.Object.create
      id: 99

    Ember.run =>
      @ctrl = @subject()
      @ctrl.set('model', @task)

  afterEach: ->
    RESTless.putModel.restore()  # reset sinon stub

test 'sendEmail calls send_message endpoint', (assert)->
  @subject().send 'sendEmail', 'Foo'
  ok RESTless.putModel.getCall(0).args[2].task == 'Foo'

test 'imageUploadUrl updates when model is changed', (assert)->
  assert.equal "/api/tasks/99/attachments", @ctrl.get('imageUploadUrl')
  @ctrl.get('model').set('id', 111)
  assert.equal "/api/tasks/111/attachments", @ctrl.get('imageUploadUrl')
