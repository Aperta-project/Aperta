ETahi.VisualEditorService = Em.Object.extend
  init: ->
    ve.init.platform.setModulesUrl('/visual-editor/modules')

  update: ($parent, content) ->
    container = $('<div>')
    $parent.html('').append(container)
    ve.debug = false # it's true by default, which adds a gray background
                     # on initialize and update
    target = new ve.init.sa.Target(
      container,
      ve.createDocumentFromHtml(content || '')
    )
    target.on('surfaceReady', ->
      target.toolbar.disableFloatable()
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
    @get("target").surface.enable()

  disable: () ->
    @get("target").surface.disable()
