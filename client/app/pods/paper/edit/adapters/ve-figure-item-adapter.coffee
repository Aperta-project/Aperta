`import Ember from 'ember'`

VEFigureItemAdapter = Ember.Object.extend

  figure: null
  component: null

  # instance of 'tahi-editor-extensions/form/form-node'
  # which conains two form-entries for 'title' and 'caption'
  node: null
  propertyNodes: null
  cachedValues: null

  registerBindings: ( ->
    figure = @get('figure')
    node = @get('node')
    titleNode = null
    captionNode = null
    node.traverse( (node) ->
      if node.type == 'textInput' and node.getPropertyName() == 'title'
        titleNode = node
      else if node.type == 'textInput' and node.getPropertyName() == 'caption'
        captionNode = node
    )
    if not titleNode or not captionNode
      console.error('Could not find title and caption node...')

    @propertyNodes =
      title: titleNode
      caption: captionNode
    @cachedValues =
      title: figure.get('title')
      caption: figure.get('caption')
  ).on('init')


  connect: ->
    # only title and caption can be changed via 'VisualEditor'
    # The image is handled emberly
    figure = @get('figure')
    @propertyNodes.title.connect(@,
      "change": @propertyEdited
    )
    @propertyNodes.caption.connect(@,
      "change": @propertyEdited
    )
    return @

  disconnect: ->
    figure = @get('figure')
    @propertyNodes.title.disconnect @
    @propertyNodes.caption.disconnect @
    return @

  propertyEdited: (propertyName, newValue) ->
    figure = @get('figure')
    oldValue = figure.get(propertyName)
    if oldValue != newValue
      @cachedValues[propertyName] = newValue
      figure.set(propertyName, newValue)
      # console.log('FigureItemAdapter: updated %s. saving...', propertyName)
      @get('component').send('saveFigure')

  # Note: model changes are not handled here
  #   as this dialog can only be opened when editing the paper, thus the paper is locked
  #   TODO: is it so, that figures are also locked then?

`export default VEFigureItemAdapter`
