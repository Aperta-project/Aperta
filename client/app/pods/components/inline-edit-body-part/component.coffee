`import Ember from 'ember'`

InlineEditBodyPartComponent = Ember.Component.extend
  editing: false
  snapshot: null
  confirmDelete: false

  _init: (->
    @set 'snapshot', []
  ).on('init')

  createSnapshot: (->
    @set('snapshot', Ember.copy(@get('block'), true))
  ).observes('editing')

  hasContent: (->
    @get('block').any(@_isNotEmpty)
  ).property('block.@each.value')

  hasNoContent: Ember.computed.not('hasContent')

  bodyPartType: (->
    @get('block.firstObject.type')
  ).property('block.@each.type')

  _isNotEmpty: (item) ->
    item && !Ember.isEmpty(item.value)

  actions:
    toggleEdit: ->
      @sendAction('cancel', @get('block'), @get('snapshot')) if @get('editing')
      @toggleProperty 'editing'

    deleteBlock: ->
      @sendAction('delete', @get('block'))

    save: ->
      if @get('hasContent')
        @sendAction('save', @get('block'))
        @toggleProperty 'editing'

    confirmDeletion: ->
      @set('confirmDelete', true)

    cancelDeletion: ->
      @set('confirmDelete', false)

    addItem: ->
      @sendAction('addItem', @get('block'))

`export default InlineEditBodyPartComponent`
