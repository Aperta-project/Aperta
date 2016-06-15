`import Ember from 'ember'`
`import { test, moduleForComponent } from 'ember-qunit'`
`import startApp from '../helpers/start-app'`
`import setupMockServer from '../helpers/mock-server'`

server = null

moduleForComponent 'select-2', 'Unit: components/select-2',
  unit: true

  beforeEach: ->
    startApp()
    server = setupMockServer()

    server.respondWith 'GET', /filtered_objects.*/, [
      200, {"Content-Type": "application/json"}, JSON.stringify [{id: 1, text: 'Aaron'}]
    ]

  afterEach: ->
    server.restore()

# TODO: Use pcikfromselect2 helper
fillInDropdown = (object) ->
  keyEvent('.select2-container input', 'keydown')
  fillIn('.select2-container input', object)
  keyEvent('.select2-container input', 'keyup')

selectObjectFromDropdown = (object) ->
  fillInDropdown(object)
  click('.select2-result-selectable', 'body')

appendBasicComponent = (context) ->
  Ember.run =>
    context.component = context.subject()
    context.component.setProperties
      multiSelect: true
      source: [{id: 1, text: '1'}
               {id: 2, text: '2'}
               {id: 3, text: '3'}]
  context.render()

test "User can make a selection from the dropdown", (assert) ->
  appendBasicComponent(this)
  selectObjectFromDropdown('1')
  andThen ->
    assert.ok $('.select2-container').select2('val').contains("1"), 'Selection made'

test "User can remove a selection from the dropdown", (assert) ->
  appendBasicComponent(this)

  @component.setProperties
    selectedData: [{id: 1, text: '1'}]

  assert.ok $('.select2-container').select2('val').contains("1"), 'Selection made'

  click('.select2-search-choice-close').then ->
    assert.ok !$('.select2-container').select2('val').contains("1"), 'removed'

test "Making a selection should trigger a callback to add the object", (assert) ->
  appendBasicComponent(this)
  targetObject =
    externalAction: (choice) ->
      assert.equal choice.id, '1'

  @component.set 'selectionSelected', 'externalAction'
  @component.set 'targetObject', targetObject
  selectObjectFromDropdown('1')

test "Removing a selection should trigger a callback to remove the object", (assert) ->
  appendBasicComponent(this)

  @component.setProperties
    selectedData: [{id: 1, text: '1'}]

  targetObject =
    externalAction: (choice) ->
      assert.equal choice.id, '1'

  @component.set('selectionRemoved', 'externalAction')
  @component.set('targetObject', targetObject)
  click('.select2-search-choice-close')

test "Typing more than 3 letters with a remote url should make a call to said remote url", (assert) ->
  Ember.run =>
    @component = @subject()
    @component.setProperties
      multiSelect: true
      source: []
      remoteSource:
        url: "filtered_objects"
        dataType: "json"
        data: (term) ->
          query: term
        results: (data) ->
          results: data

  @render()

  keyEvent('.select2-container input', 'keydown')
  fillIn('.select2-container input', 'Aaron')
  keyEvent('.select2-container input', 'keyup')
  waitForElement('.select2-result-selectable')

  andThen ->
    assert.ok find('.select2-result-selectable', 'body').length

test "Event stream object added should add the object to the selected objects in the dropdown", (assert) ->
  Ember.run =>
    @component = @subject()
    @component.setProperties
      multiSelect: true
      source: [{id: 1, text: '1'}, {id: 2, text: '2'}, {id: 3, text: '3'}]
  @render()

  assert.ok !$('.select2-container').select2('val').contains("4")

  # event stream will update this property when a user is added
  @component.setProperties
    selectedData: [{id: 4, text: '4'}]
  assert.ok $('.select2-container').select2('val').contains("4")

test "Event stream object removed should remove the object from the selected objects in the dropdown", (assert) ->
  appendBasicComponent(this)

  @component.setProperties
    selectedData: [{id: 4, text: '4'}]
  assert.ok $('.select2-container').select2('val').contains("4")

  @component.setProperties
    selectedData: []
  assert.ok !$('.select2-container').select2('val').contains("4")
