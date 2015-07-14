`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`
`import RESTless from 'tahi/services/rest-less'`

moduleFor 'controller:overlays/ad-hoc', 'AdHocOverlayController',
  needs: ['controller:application', 'controller:paper/task']
  afterEach: ->
    RESTless.putModel.restore() # reset sinon stub

test 'sendEmail calls send_message endpoint', (assert) ->
  sinon.stub(RESTless, 'putModel')
  @subject().send 'sendEmail', 'Foo'
  assert.ok RESTless.putModel.getCall(0).args[2].task == 'Foo'
