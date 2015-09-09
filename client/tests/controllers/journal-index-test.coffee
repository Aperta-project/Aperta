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

test '#destroyMMTemplate does not delete the last MMT', (assert) ->
  Ember.run =>
    @journal.set('manuscriptManagerTemplates', [])
    @controller.set('model', @journal)
    @mmt = @store.createRecord('manuscriptManagerTemplate', paperType: 'research')
    @controller.get('model.manuscriptManagerTemplates').addObject(@mmt)
    @controller.send 'destroyMMTemplate', @mmt

  assert.equal(@controller.get('model.manuscriptManagerTemplates.length'), 1)

test '#destroyMMTemplate deletes the given MMT when there are more than one MMTs', (assert) ->
  handler = ()->

  Ember.run =>
    @mmt  = @store.createRecord('manuscriptManagerTemplate', paperType: 'research')
    @mmt2 = @store.createRecord('manuscriptManagerTemplate', paperType: 'hcraeser')
    @journal.set('manuscriptManagerTemplates', [@mmt, @mmt2])
    @controller.set('model', @journal)

  sinon.stub(@mmt2, 'destroyRecord').returns(new Ember.RSVP.Promise(handler, handler))
  assert.equal(@controller.get('model.manuscriptManagerTemplates.length'), 2)
  Ember.run =>
    @controller.send 'destroyMMTemplate', @mmt2
    assert.ok @mmt2.destroyRecord.called
