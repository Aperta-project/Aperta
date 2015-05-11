`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`
`import RESTless from 'tahi/services/rest-less'`

moduleFor 'controller:overlays/ad-hoc', 'AdHocOverlayController',
  needs: ['controller:application', 'controller:paper/task']
  teardown: ->
    RESTless.putModel.restore() # reset sinon stub

test 'sendEmail calls send_message endpoint', ->
  sinon.stub(RESTless, 'putModel')
  @subject().send 'sendEmail', 'Foo'
  ok RESTless.putModel.getCall(0).args[2].task == 'Foo'
