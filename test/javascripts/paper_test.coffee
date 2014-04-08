#= require test_helper

emq.globalize()
ETahi.injectTestHelpers()
ETahi.Resolver = Ember.DefaultResolver.extend namespace: ETahi
setResolver ETahi.__container__

ETahi.setupForTesting()

moduleForModel 'paper', 'Unit: Paper Model',
  needs: ['model:user', 'model:declaration', 'model:figure', 'model:journal', 'model:phase']

test 'displayTitle displays short title if title is missing', ->
  debugger
  paper = @subject
    title: ''
    shortTitle: 'test short title'
  equal paper.get('displayTitle'), 'test short title'

  paper.setProperties
    title: 'Hello world'

  equal paper.get('displayTitle'), 'Hello world'
