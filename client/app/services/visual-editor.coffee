`import Ember from 'ember'`

VisualEditorService = Ember.Object.extend
  init: ->
    ve.init.platform.setModulesUrl('/visual-editor/modules')

  isEnabled: false
  isFocused: false
  isCurrentlyEditing: Ember.computed.and('isEnabled', 'isFocused')

  update: ($parent, content) ->
    container = $('<div>')
    $parent.html('').append(container)
    ve.debug = false # it's true by default, which adds a gray background
                     # on initialize and update
    target = new ve.init.sa.Target(
      container,
      ve.createDocumentFromHtml(content || '')
    )
    self = @
    target.on('surfaceReady', ->
      target.toolbar.disableFloatable()

      surfaceView = target.surface.getView()
      surfaceView.on 'focus', ->
        self.set('isFocused', true)
      surfaceView.on 'blur', ->
        self.set('isFocused', false)
    )
    @set('target', target)

  bodyHtml: (->
    surf = @get('target').surface
    documentNode = ve.dm.converter.getDomFromModel(surf.getModel().getDocument())
    $(documentNode).find('body').html()
  ).property().volatile()

  isEmpty: (->
    Ember.isBlank Ember.$(@get('bodyHtml')).text()
  ).property().volatile()

  enable: () ->
    if target = @get('target')
      target.surface.enable()
      @setProperties
        isEnabled: true
        isFocused: false

  disable: () ->
    if target = @get('target')
      @get("target").surface.disable()
      @set('isEnabled', false)

  startEditing: ->
    if @get('isEnabled')
      @get('target').surface.getView().focus()
      @set('isFocused', true)

`export default VisualEditorService`
