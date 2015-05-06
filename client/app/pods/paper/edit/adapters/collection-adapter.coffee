`import Ember from 'ember';`

# Observes items of a table collection and updates the corresponding VE model or the Ember model vice versa.
CollectionAdapterMixin = Ember.Mixin.create

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

  isSaving: false

  getUpdateTimestamp: (model) ->
    model.get('updatedAt') || model.get('createdAt')

  initialize: ( () ->
    updatedAt = {}
    dirtyModels = {}
    @get('collection').forEach( (model) =>
      id = model.get('id')
      @connectModel(model)
      dirtyModels[id] = model
    )
    @get('collection').addArrayObserver(@,
      willChange: (collection, offset, removeCount) ->
        for idx in [offset...offset+removeCount]
          @disconnectModel(collection.objectAt(idx))
      didChange: (collection, offset, removeCount, addCount) ->
        for idx in [offset...offset+addCount]
          @connectModel(collection.objectAt(idx))
    )
    docEventHandlers = {}
    docEventHandlers[@get('editEvent')] = @onEdit
    @get('doc').connect @, docEventHandlers
    @getNodeIndex().connect @,
      add: @nodeAdded

    @set('updatedAt', updatedAt)
    @set('dirtyNodes', {})
    @set('dirtyModels', dirtyModels)

    @loadUpdatedModels()
  ).on('init')

  willDestroy: ( () ->
    console.log('Destroying collection adapter for', @get('modelType'))
    @_super()
    @get('doc').disconnect @
    @getNodeIndex().disconnect @
    @get('collection').forEach( (model) =>
      @disconnectModel(model)
    )
  ).on('willDestroy')

  connectModel: (model) ->
    @get('editableFields').forEach (prop) =>
      model.addObserver(prop, @, @onModelChange)

  disconnectModel: (model) ->
    return unless model
    @get('editableFields').forEach (prop) =>
      model.removeObserver(prop, @, @onModelChange)

  nodeAdded: (node) ->
    @get('paper').store.findById(@get('modelType'), node.getId()).then (model) =>
      @loadFromModel(model)

  onModelChange: (model) ->
    @get('dirtyModels')[model.get('id')] = model
    @loadDebounced()

  onEdit: (node) ->
    return if @get('isUpdating')
    @get('dirtyNodes')[node.getId()] = node
    @saveDebounced()

  saveDirtyNodes: ->
    return if @get('isDestroyed')

    dirtyNodes = @get('dirtyNodes')
    @set('dirtyNodes', {})
    @set('isSaving', true)
    for id, node of dirtyNodes
      @saveToModel(node)
    @set('isSaving', false)

  saveToModel: (node) ->
    @get('paper').store.findById(@get('modelType'), node.getId()).then (model) =>
      @saveNodeToModel(node, model)
      if (model.get('isDirty'))
        model.set('updatedAt', new Date())
        model.save()

  loadUpdatedModels: ->
    return if @get('isDestroyed')

    dirtyModels = @get('dirtyModels')
    @set('dirtyModels', {})
    for id, model of dirtyModels
      @loadFromModel(model)

  loadFromModel: (model) ->
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
        @loadNodeFromModel(node, model)
      editor.breakpoint()
      @set('isUpdating', false)
      @get('updatedAt')[id] = updatedAt

  saveDebounced: ->
    Ember.run.debounce(@, @saveDirtyNodes, 2000);

  loadDebounced: ->
    Ember.run.debounce(@, @loadUpdatedModels, 100);

`export default CollectionAdapterMixin;`
