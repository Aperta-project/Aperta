`import Ember from 'ember'`

VETableItemAdapter = Ember.Object.extend

  table: null
  component: null

  # instance of 'tahi-editor-extensions/figures/figure'
  node: null
  propertyNodes: null
  cachedValues: null

  observedProperties: ['title', 'caption', 'tableHtml']

  registerBindings: ( ->
    table = @get('table')
    node = @get('node')
    titleNode = null
    captionNode = null
    tableNode = null
    node.traverse( (node) ->
      if node.type == 'figureTitle'
        titleNode = node
      else if node.type == 'figureTable'
        tableNode = node
      else if node.type == 'textInput' and node.getPropertyName() == 'caption'
        captionNode = node
    )
    if not titleNode or not tableNode or not captionNode
      console.error('Could not find nodes.')

    @propertyNodes =
      title: titleNode
      tableHtml: tableNode
      caption: captionNode
    @cachedValues =
      title: table.get('title')
      tableHtml: table.get('tableHtml')
      caption: table.get('caption')
  ).on('init')


  connect: ->
    # only title and caption can be changed via 'VisualEditor'
    # The image is handled emberly
    table = @get('table')
    for propertyName in @observedProperties
      @propertyNodes[propertyName].connect @,
        "change": @propertyEdited
    return @

  disconnect: ->
    table = @get('table')
    for propertyName in @observedProperties
      @propertyNodes[propertyName].disconnect @
    return @

  propertyEdited: (propertyName, newValue) ->
    table = @get('table')
    oldValue = table.get(propertyName)
    if oldValue != newValue
      @cachedValues[propertyName] = newValue
      table.set(propertyName, newValue)
      @get('component').send('saveTable')

`export default VETableItemAdapter`
