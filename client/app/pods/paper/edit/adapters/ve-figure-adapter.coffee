`import Ember from 'ember'`

VEFigureAdapter = Ember.Object.extend

  controller: null
  figure: null
  node: null
  propertyNodes: null
  cachedValues: null
  observedProperties: [ 'title', 'caption', 'src' ]
  editableProperties: [ 'title', 'caption' ]

  init: ->
    @_super()

    figure = @get('figure')
    node = @get('node')
    titleNode = null
    imgNode = null
    captionNode = null
    node.traverse( (node) ->
      if node.type == 'figureTitle'
        titleNode = node
      else if node.type == 'textInput' and node.getPropertyName() == 'caption'
        captionNode = node
      else if node.type == 'figureImage'
        imgNode = node
    )
    @propertyNodes =
      title: titleNode
      caption: captionNode
      src: imgNode
    @cachedValues =
      title: figure.get('title')
      caption: figure.get('caption')
      src: figure.get('src')

  loadFromModel: ->
    figure = @get('figure')
    # console.log('loading data from figure', figure.get('id'))
    for propertyName in @observedProperties
      # console.log('    %s: %s', propertyName, figure.get(propertyName))
      @updatePropertyNode propertyName, figure.get(propertyName)
    false

  connect: ->
    figure = @get('figure')
    # console.log('connecting figure %s with node %s', figure.get('id'), @get('node').getId())
    # Note: ATM only title and caption can be edited from within the manuscript editor
    for propertyName in @editableProperties
      @propertyNodes[propertyName].connect @,
        "change": @propertyEdited

    for propertyName in @observedProperties
      figure.addObserver(propertyName, @, @modelChanged)

    return @

  disconnect: ->
    figure = @get('figure')
    for propertyName in @observedProperties
      @propertyNodes[propertyName].disconnect @
      figure.removeObserver(propertyName, @, @modelChanged)
    return @

  dispose: ->
    @disconnect()

  propertyEdited: (propertyName, newValue) ->
    figure = @get('figure')
    oldValue = figure.get(propertyName)
    if oldValue != newValue
      # console.log('FigureAdapter.propertyEdited', propertyName, newValue)
      @cachedValues[propertyName] = newValue
      figure.set(propertyName, newValue)
      figure.saveDebounced()

  updatePropertyNode: (propertyName, value) ->
    propertyNode = @propertyNodes[propertyName]
    unless propertyNode
      return
    # Note: we need to wrap the low-level change into a 'undoable' action
    controller = @get('controller')
    editor = controller.get('editor')
    editor.breakpoint()
    switch propertyName
      when 'title', 'caption' then propertyNode.fromHtml(value)
      when 'src'
        # HACK: inhibiting saves triggered by changes to the image URL
        # as this generates a new URL on the server leading to an infinite loop
        controller.set('inhibitSave', true)
        propertyNode.setAttributes
          src: value
        controller.set('inhibitSave', false)
    editor.breakpoint()

  modelChanged: (figure, propertyName) ->
    controller = @get('controller')
    # Note: we allow model updates only if the manuscript is not edited.
    # Either if editing is turned off, or if the user is in an editor overlay
    if controller.get('isEditing') and not controller.get('hasOverlay')
      return

    oldValue = @cachedValues[propertyName]
    newValue = figure.get(propertyName)
    if oldValue != newValue
      # console.log('Model of figure %s has changed for property %s', figure.get('id'), propertyName)
      @updatePropertyNode(propertyName, newValue)
      @cachedValues[propertyName] = newValue

`export default VEFigureAdapter`
