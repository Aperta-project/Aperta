#= require test_helper

emq.globalize()
ETahi.setupForTesting()
ETahi.injectTestHelpers()
ETahi.Resolver = Ember.DefaultResolver.extend namespace: ETahi
setResolver ETahi.Resolver.create()

ETahi.setupForTesting()

moduleForModel 'paper', 'Unit: Paper Model'
moduleForModel 'user', 'Unit: User Model'

test 'displayTitle displays short title if title is missing', ->
  paper = @subject
    title: ''
    shortTitle: 'test short title'
  displayTitle = paper.get('displayTitle')
  equal displayTitle, 'test short title'
