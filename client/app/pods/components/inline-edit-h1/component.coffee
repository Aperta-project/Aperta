`import Ember from 'ember'`

InlineEditH1Component = Ember.Component.extend
  editing: Ember.computed.oneWay 'editOnOpen'
  snapshot: null

  createSnapshot: (->
    @set('snapshot', Em.copy(@get('title')))
  ).observes('editing')

  hasContent: Ember.computed.notEmpty('title')

  focusOnEdit: (->
    if @get('editing')
      Ember.run.schedule 'afterRender', @, ->
        @$('input[type=text]').focus().select()
  ).observes('editing').on('didInsertElement')

  actions:
    toggleEdit: ->
      @sendAction('setTitle', @get('snapshot')) if @get('editing')
      @toggleProperty 'editing'

    save: ->
      if @get('hasContent')
        @sendAction('setTitle', @get('title'))
        @toggleProperty 'editing'

`export default InlineEditH1Component`
