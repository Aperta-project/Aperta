`import Ember from 'ember'`
`import { test, moduleFor } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`

moduleFor 'controller:admin/journal/index', 'JournalIndexController',
  beforeEach: ->
    startApp()
    @store = getStore()

    @journal = Ember.Object.create
      title: 'test journal'

    @journalWithLogo = Ember.Object.create
      title: 'test journal with logo'
      logoUrl: 'http://example.com/test.png'

    Ember.run =>
      @controller = @subject()

test '#logo returns false if a logoUrl doesnt exist', ->
  @controller.set('model', @journal)
  equal @controller.get('logo'), false

test '#logo returns model.logoUrl if it exists', ->
  @controller.set('model', @journalWithLogo)
  equal @controller.get('logo'), @journalWithLogo.logoUrl

test '#destroyMMTemplate does not delete the last MMT', ->
  Ember.run =>
    @journal.set('manuscriptManagerTemplates', [])
    @controller.set('model', @journal)
    @mmt = @store.createRecord('manuscriptManagerTemplate', paperType: 'research')
    @controller.get('model.manuscriptManagerTemplates').addObject(@mmt)
    @controller.send 'destroyMMTemplate', @mmt

  equal(@controller.get('model.manuscriptManagerTemplates.length'), 1)

test '#destroyMMTemplate deletes the given MMT when there are more than one MMTs', ->
  handler = ()->

  Ember.run =>
    @mmt  = @store.createRecord('manuscriptManagerTemplate', paperType: 'research')
    @mmt2 = @store.createRecord('manuscriptManagerTemplate', paperType: 'hcraeser')
    @journal.set('manuscriptManagerTemplates', [@mmt, @mmt2])
    @controller.set('model', @journal)

  sinon.stub(@mmt2, 'destroyRecord').returns(new Ember.RSVP.Promise(handler, handler))
  equal(@controller.get('model.manuscriptManagerTemplates.length'), 2)
  Ember.run =>
    @controller.send 'destroyMMTemplate', @mmt2
    ok @mmt2.destroyRecord.called
