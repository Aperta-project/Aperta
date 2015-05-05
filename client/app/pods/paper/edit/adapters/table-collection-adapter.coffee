`import Ember from 'ember'`

# Observes items of a table collection and updates the corresponding VE model or the Ember model vice versa.
TableCollectionAdapter = Ember.Object.extend

  doc: null
  paper: null
  # NOTE: we need an editor instance to be able to set an history recovery point
  # when transferring updates from the model to the editor.
  editor: null

  # Used to detect changes in the backend; i.e., when the model is updated by the backend
  # the updatedAt property should have changed and we need to update the VE node
  updatedAt: null
  dirtyNodes: null
  dirtyModels: null

  getUpdateTimestamp: (model) ->
    model.get('updatedAt') || model.get('createdAt')

  initialize: ( () ->
    updatedAt = {}
    dirtyModels = {}
    @get('paper.tables').forEach( (table) =>
      id = table.get('id')
      @connectModel(table)
      dirtyModels[id] = table
    )
    @get('paper.tables').addArrayObserver(@,
      willChange: (tables, offset, removeCount) ->
        for idx in [offset...offset+removeCount]
          @disconnectModel(tables.objectAt(idx))
      didChange: (tables, offset, removeCount, addCount) ->
        for idx in [offset...offset+addCount]
          @connectModel(tables.objectAt(idx))
    )
    @get('doc').connect @,
      'table:edited': @onEdit
    @get('doc').getIndex('table-nodes').connect @,
      add: @nodeAdded

    @set('updatedAt', updatedAt)
    @set('dirtyNodes', {})
    @set('dirtyModels', dirtyModels)

    @loadUpdatedModels()
  ).on('init')

  willDestroy: ( () ->
    @_super()
    @get('doc').disconnect @
    @get('doc').getIndex('table-nodes').disconnect @
    @get('paper.tables').forEach( (table) =>
      @disconnectModel(table)
    )
  ).on('willDestroy')

  connectModel: (table) ->
    table.addObserver('title', @, @onModelChange)
    table.addObserver('body', @, @onModelChange)
    table.addObserver('caption', @, @onModelChange)

  disconnectModel: (table) ->
    return unless table
    table.removeObserver('title', @, @onModelChange)
    table.removeObserver('body', @, @onModelChange)
    table.removeObserver('caption', @, @onModelChange)

  nodeAdded: (node) ->
    @get('paper').store.findById('table', node.getId()).then (table) =>
      @loadModel(table)

  onModelChange: (model) ->
    @get('dirtyModels')[model.get('id')] = model
    @loadDebounced()

  onEdit: (node) ->
    return if @get('isUpdating')
    @get('dirtyNodes')[node.getId()] = node
    @saveDebounced()

  saveDirtyNodes: ->
    dirtyNodes = @get('dirtyNodes')
    @set('dirtyNodes', {})
    for id, node of dirtyNodes
      @saveNode(node)

  saveNode: (node) ->
    @get('paper').store.findById('table', node.getId()).then (table) =>
      newTitle = node.getPropertyNode('title').toHtml()
      table.set('title', newTitle)
      newBody = node.getPropertyNode('table').toHtml()
      table.set('body', newBody)
      newCaption = node.getPropertyNode('caption').toHtml()
      table.set('caption', newCaption)
      if (table.get('isDirty'))
        console.log('Saving table node', table.get('id'))
        table.set('updatedAt', new Date())
        table.save()

  loadUpdatedModels: ->
    dirtyModels = @get('dirtyModels')
    @set('dirtyModels', {})
    for id, model of dirtyModels
      @loadModel(model)

  loadModel: (model) ->
    id = model.get('id')
    updatedAt = @getUpdateTimestamp(model)
    oldUpdatedAt = @get('updatedAt')[id]
    # only update if updatedAt timestamp has changed
    return if oldUpdatedAt and ( updatedAt.getTime() <= oldUpdatedAt.getTime() )
    tableNodes = @get('doc').getIndex('table-nodes')
    # Note: there are potentially multiple nodes associated with one collection item
    nodes = tableNodes.getById(id)
    if nodes.length > 0
      @set('isUpdating', true)
      editor = @get('editor')
      editor.breakpoint()
      for node in nodes
        oldTitle = node.getPropertyNode('title').toHtml()
        oldBody = node.getPropertyNode('table').toHtml()
        oldCaption = node.getPropertyNode('caption').toHtml()
        newTitle = model.get('title')
        newBody = model.get('body')
        newCaption = model.get('caption')
        if oldTitle != newTitle
          node.getPropertyNode('title').fromHtml(newTitle)
        if oldBody != newBody
          node.getPropertyNode('table').fromHtml(newBody)
        if oldCaption != newCaption
          node.getPropertyNode('caption').fromHtml(newCaption)
      editor.breakpoint()
      @set('isUpdating', false)
      @get('updatedAt')[id] = updatedAt

  saveDebounced: ->
    Ember.run.debounce(@, @saveDirtyNodes, 2000);

  loadDebounced: ->
    Ember.run.debounce(@, @loadUpdatedModels, 100);

`export default TableCollectionAdapter`
