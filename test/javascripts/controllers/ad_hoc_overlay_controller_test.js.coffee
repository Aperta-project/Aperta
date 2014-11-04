moduleFor 'controller:adHocOverlay', 'AdHocOverlayController',
  needs: ['controller:application', 'controller:task']
  teardown: ->
    ETahi.RESTless.putModel.restore() # reset sinon stub

test 'sendEmail calls send_message endpoint', ->
  sinon.stub(ETahi.RESTless, 'putModel')
  @subject().send 'sendEmail', 'Foo'
  ok ETahi.RESTless.putModel.getCall(0).args[2].task == 'Foo'
