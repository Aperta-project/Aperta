`import Ember from 'ember'`
`import { moduleFor, test } from 'ember-qunit'`

moduleFor 'route:paper/index', 'Unit: route/PaperIndex',
  needs: ['model:paper', 'route:paper'],
  beforeEach: ->
    sinon.stub(@subject(), 'replaceWith')

test 'transition to edit route if paper is editable', (assert) ->
  editablePaper = Ember.Object.create editable: true
  @subject().afterModel editablePaper

  assert.ok @subject().replaceWith.calledWithExactly('paper.edit', editablePaper)

test 'does not transition to edit route if paper has been submitted', (assert) ->
  uneditablePaper = Ember.Object.create editable: false
  @subject().afterModel uneditablePaper

  assert.ok !@subject().replaceWith.called
