`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`

moduleFor 'controller:admin/journal/index', 'JournalIndexController',
  setup: ->
    startApp()

    @journal = Ember.Object.create
      title: 'test journal'

    @journalWithLogo = Ember.Object.create
      title: 'test journal with logo'
      logoUrl: 'http://example.com/test.png'

    Ember.run =>
      @controller = @subject()

test '#logo return logoUrl if it exists else return Journal name', ->
  @controller.set('model', @journal)
  equal @controller.get("logo"), undefined
  equal @controller.get("logoUrl"), undefined

test '#logo return logoUrl if it exists else return Journal name', ->
  @controller.set('model', @journalWithLogo)
  equal @controller.get("logo"), @journalWithLogo.logoUrl
  equal @controller.get("logoUrl"), @journalWithLogo.logoUrl
