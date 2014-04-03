Ember.ContentEditableView = Em.View.extend
  tagName: 'div'
  attributeBindings: ['contenteditable', 'placeholder']

  # Variables:
  editable: false
  isUserTyping: false
  plaintext: false

  # Properties:
  contenteditable: (->
    editable = @get('editable')
    (if editable then 'true' else `undefined`)
  ).property('editable')

  # Observers:
  valueObserver: (->
    @setContent()  if not @get('isUserTyping') and @get('value')
  ).observes('value')

  # Events:
  didInsertElement: ->
    @setContent()

  focusOut: ->
    @set 'isUserTyping', false

  keyDown: (event) ->
    @set 'isUserTyping', true  unless event.metaKey

  keyUp: (event) ->
    if @get('plaintext')
      @set 'value', @$().text()
    else
      @set 'value', @$().html()

  setContent: ->
    @$().html @get('value')
