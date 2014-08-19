ETahi.Factory =

  typeIds: {}

  getNewId: (type) ->
    typeIds = @typeIds
    if !typeIds[type]
      typeIds[type] = 0
    typeIds[type] += 1
    typeIds[type]

  createPhase: (paper, attrs={})  ->
    newPhase = @createRecord('Phase', attrs)
    @addHasMany(paper, [newPhase], {inverse: 'paper'})
    newPhase

  createTask: (type, paper, phase, attrs={}) ->
    newTask = @createRecord(type, _.extend(attrs, {lite_paper_id: paper.id}))
    @addHasMany(paper, [newTask], {inverse: 'paper', embed: true})
    @addHasMany(phase, [newTask], {inverse: 'phase', embed: true})
    newTask

  createRecord: (type, attrs={}) ->
    if !attrs.id #make a new id if it wasn't passed in.
      newId = @getNewId(type)
      recordAttrs = _.extend(attrs, {id: newId})
    else
      recordAttrs = attrs

    baseAttrs = ETahi.FactoryAttributes[type]
    throw "No factory exists for type: #{type}" unless baseAttrs
    _.defaults(recordAttrs, baseAttrs)

  setForeignKey: (model, sourceModel, options={}) ->
    keyName = options.keyName || sourceModel._rootKey
    model[keyName + "_id"] = sourceModel.id
    if inverseKeyName = options.inverse
      @setForeignKey(sourceModel, model, {keyName: inverseKeyName})
    [model, sourceModel]

  addHasMany: (model, models, options) ->
    @setHasMany(model, models, _.extend(options, {merge: true}))

  mergeArrays: (model, key, values) ->
    model[key] ||= []
    currentValues = model[key]
    model[key] = _.union(currentValues, values)

  setHasMany: (model, models, options={}) ->
    keyName = options.keyName || _.first(models)._rootKey
    key = keyName + "_ids"

    if options.embed
      modelIds = _.map(models, (t) -> {id: t.id, type: t.type})
    else
      modelIds = _.pluck(models, "id")

    if options.merge
      @mergeArrays(model, key, modelIds)
    else
      model[key] = modelIds

    if inverseKeyName = options.inverse
      _.forEach models, (m) =>
        @setForeignKey(m, model, {keyName: inverseKeyName})
    [model, models]

  addEmbeddedHasMany: (model, models, options) ->
    @setEmbeddedHasMany(model, models, _.extend(options, {merge: true}))

  setEmbeddedHasMany: (model, models, options={}) ->
    @setHasMany(model, models, _.extend(options, {embed: true}))

  createBasicPaper: (defs) ->
    ef = ETahi.Factory
    # create the records
    journal = ef.createRecord('Journal', defs.journal || {})
    paper = ef.createRecord('Paper', _.omit(defs.paper, 'phases') || {})
    litePaper = ETahi.Factory.createLitePaper(paper)
    ef.setForeignKey(paper, journal)

    phasesAndTasks = _.map(defs.paper.phases, (phase) ->
      phaseRecord = ef.createRecord('Phase', _.omit(phase, 'tasks'))
      taskRecords = _.map(phase.tasks, (task) ->
        taskType = _.keys(task)[0]
        taskAttrs = task[taskType]
        ef.createRecord(taskType, taskAttrs))

      #associate phases and tasks
      ef.setEmbeddedHasMany(phaseRecord, taskRecords, {inverse: 'phase'})
      [phaseRecord, taskRecords]
    )
    allTasks = _.reduce(phasesAndTasks, ((memo, [phase, tasks]) -> memo.concat(tasks)), [])
    phases = _.map(phasesAndTasks, _.first)

    # associate paper to phases and paper to tasks
    ef.setHasMany(paper, phases, {inverse: 'paper'})
    ef.setEmbeddedHasMany(paper, allTasks, {inverse: 'paper'})
    _.forEach(allTasks, (task) -> task.lite_paper_id = paper.id)

    [].concat(paper, litePaper, journal, phases, allTasks)

  addRecordToManifest: (manifest, typeName, obj, isPrimary) ->
    # the allRecords array allows easy modification of a given
    # record later
    manifest.allRecords ||= []
    manifest.allRecords.addObject(obj)

    manifest.types ||= {}
    types = manifest.types
    typeArray = types[typeName]
    if !typeArray
      types[typeName] = []
      typeArray = types[typeName]
    typeArray.addObject(obj)

    if isPrimary
      manifest.primaryRecord = obj
      manifest.primaryType = typeName
    manifest

  manifestToPayload: (manifest) ->
    {primaryRecord, primaryType} = manifest
    payload = {}
    payload[primaryType] = primaryRecord
    _.forEach manifest.types, (typeArray, typeName) ->
      records = _.map(typeArray, (d) -> d)
      if typeName == primaryType
        records = _.reject(records, (r) -> r == primaryRecord)
      if records.length > 0
        payload[(typeName + "s")] = records
    payload

   createPayload: (primaryTypeName) ->
     _addRecordToManifest = @addRecordToManifest
     _manifestToPayload = @manifestToPayload
     manifest: {types: {}}

     createRecord: (type, attrs) ->
       newRecord = ETahi.Factory.createRecord(type, attrs)
       @addRecord(newRecord)
       newRecord

     addRecords: (records, options={}) ->
       _.forEach(records, (r) => @addRecord(r, options))
       @

     addRecord: (record, options={}) ->
       rootKey = options.rootKey || record._rootKey
       isPrimary = (rootKey == primaryTypeName)
       @manifest = _addRecordToManifest(@manifest, rootKey, record, isPrimary)
       @

     toJSON: ->
       _manifestToPayload(@manifest)

  createLitePaper: (paper) ->
    {short_title, title, id, submitted} = paper
    paper_id = id
    paperAttrs = {short_title, title, id, submitted, paper_id}
    ETahi.Factory.createRecord('LitePaper', paperAttrs)

ETahi.FactoryAttributes = {}
ETahi.FactoryAttributes.User =
  _rootKey: 'user'
  id: null
  full_name: "Fake User"
  avatar_url: "/images/profile-no-image.png"
  username: "fakeuser"
  email: "fakeuser@example.com"
  admin: false
  affiliation_ids: []
ETahi.FactoryAttributes.Journal =
  _rootKey: 'journal'
  id: null
  name: "Fake Journal"
  logo_url: "/images/no-journal-image.gif"
  paper_types: ["Research"]
  task_types: [
    "ReviewerReportTask"
    "PaperAdminTask"
    "UploadManuscript::Task"
    "PaperEditorTask"
    "Declaration::Task"
    "PaperReviewerTask"
    "RegisterDecisionTask"
    "StandardTasks::TechCheckTask"
    "StandardTasks::FigureTask"
    "StandardTasks::AuthorsTask"
    "SupportingInformation::Task"
    "DataAvailability::Task"
    "FinancialDisclosure::Task"
    "CompetingInterests::Task"
  ]
  manuscript_css: null

ETahi.FactoryAttributes.Paper =
  _rootKey: 'paper'
  id: 1
  short_title: "Paper"
  title: "Foo"
  body: null
  submitted: false
  paper_type: "Research"
  status: null
  phase_ids: []
  figure_ids: []
  author_group_ids: []
  supporting_information_file_ids: []
  assignee_ids: []
  editor_ids: []
  reviewer_ids: []
  tasks: []
  journal_id: null

ETahi.FactoryAttributes.LitePaper =
  _rootKey: 'lite_paper'
  id: null
  title: "Foo"
  paper_id: null
  short_title: "Paper"
  submitted: false

ETahi.FactoryAttributes.MessageTask =
  _rootKey: 'task'
  id: null
  title: "Message Time"
  type: "MessageTask"
  completed: false
  body: null
  paper_title: "Foo"
  role: "author"
  phase_id: null
  paper_id: null
  lite_paper_id: null
  assignee_ids: []
  assignee_id: null
  participant_ids: []
  comment_ids: []

ETahi.FactoryAttributes.Comment =
  _rootKey: 'comment'
  id: null
  commenter_id: null
  message_task_id: null
  body: "A sample comment"
  created_at: null
  comment_look_id: null

ETahi.FactoryAttributes.CommentLook =
  _rootKey: 'comment_look'
  id: null
  read_at: null
  comment_id: null

ETahi.FactoryAttributes.Phase =
  _rootKey: 'phase'
  id: null
  name: "Submission Data"
  position: null
  paper_id: null
  tasks: []
