`import Ember from 'ember'`

RedirectsIfEditable = Em.Mixin.create
  editable: Ember.computed.alias('controller.model.editable')

  supportedDownloadFormats:
    Ember.computed.alias('controller.supportedDownloadFormats')

  toggleEditable: ->
    if @get('editable') != @get('lastEditable')
      @set('lastEditable', @get('editable'))
      @get('controller').send('editableDidChange')

  setupEditableToggle: (->
    @set('lastEditable', @get('editable'))
    @addObserver('editable', @, @toggleEditable)
  ).on('didInsertElement')

  teardownEditableToggle: (->
    @removeObserver('editable', @, @toggleEditable)
  ).on('willDestroyElement')

`export default RedirectsIfEditable`
