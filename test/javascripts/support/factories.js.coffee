ETahi.Factory =

  typeIds: {}

  resetFactoryIds: ->
    @typeIds = {}

  getNewId: (type) ->
    typeIds = @typeIds
    if !typeIds[type]
      typeIds[type] = 0
    typeIds[type] += 1
    typeIds[type]

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

    deNamespace = Tahi.utils.deNamespaceTaskType

    if options.embed
      key = keyName + "s"
      modelIds = _.map(models, (t) -> {id: t.id, type: deNamespace(t.type)})
    else
      key = keyName + "_ids"
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
    if primaryType && primaryRecord
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

  createLitePaper: (paper) ->
    {short_title, title, id, submitted} = paper
    paper_id = id
    paperAttrs = {short_title, title, id, submitted, paper_id}
    ETahi.Factory.createRecord('LitePaper', paperAttrs)

  createPhase: (paper, attrs={})  ->
    newPhase = @createRecord('Phase', attrs)
    @addHasMany(paper, [newPhase], {inverse: 'paper'})
    newPhase

  createAuthor: (paper, attrs={})  ->
    newAuthor = @createRecord('Author', attrs)
    @addHasMany(paper, [newAuthor], {inverse: 'paper'})
    newAuthor

  createTask: (type, paper, phase, attrs={}) ->
    newTask = @createRecord(type, _.extend(attrs, {lite_paper_id: paper.id}))
    @addHasMany(paper, [newTask], {inverse: 'paper', embed: true})
    @addHasMany(phase, [newTask], {inverse: 'phase', embed: true})
    newTask

  createMMT: (journal, attrs={}) ->
    newMMT = @createRecord('ManuscriptManagerTemplate', attrs)
    @addHasMany(journal, [newMMT], {inverse: 'journal'})
    newMMT

  createPhaseTemplate: (mmt, attrs={}) ->
    newPhaseTemplate = @createRecord('PhaseTemplate', attrs)
    @addHasMany(mmt, [newPhaseTemplate], {inverse: 'manuscript_manager_template'})
    newPhaseTemplate

  createJournalTaskType: (journal, taskType) ->
    jtt = @createRecord('JournalTaskType', title: taskType.title, kind: taskType.kind)
    @addHasMany(journal, [jtt], {inverse: 'journal'})
    jtt

ETahi.FactoryAttributes = {}
ETahi.FactoryAttributes.User =
  _rootKey: 'user'
  id: null
  full_name: "Fake User"
  avatar_url: "/images/profile-no-image.png"
  username: "fakeuser"
  email: "fakeuser@example.com"
  siteAdmin: false
  affiliation_ids: []

ETahi.FactoryAttributes.Journal =
  _rootKey: 'journal'
  id: null
  name: "Fake Journal"
  logo_url: "/images/no-journal-image.gif"
  paper_types: ["Research"]
  journal_task_type_ids: []
  manuscript_manager_template_ids: []
  role_ids: []
  manuscript_css: null

ETahi.FactoryAttributes.Author =
  _rootKey: 'author'
  id: null
  first_name: "Dave"
  last_name: "Thomas"
  paper_id: null
  position: 1

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
  author_ids: []
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
  roles: [] # an array of strings

ETahi.FactoryAttributes.MessageTask =
  _rootKey: 'task'
  id: null
  title: "Message Time"
  type: "MessageTask"
  completed: false
  body: []
  paper_title: "Foo"
  role: "author"
  phase_id: null
  paper_id: null
  lite_paper_id: null
  assignee_ids: []
  participant_ids: []
  comment_ids: []

ETahi.FactoryAttributes.Task =
  _rootKey: 'task'
  id: null
  title: "AdHoc Task"
  type: "Task"
  completed: false
  body: []
  paper_title: "Foo"
  role: "admin"
  phase_id: null
  paper_id: null
  lite_paper_id: null
  assignee_ids: []
  participant_ids: []
  comment_ids: []

ETahi.FactoryAttributes.FigureTask =
  _rootKey: 'task'
  id: null
  title: "Upload Figures"
  type: "FigureTask"
  completed: false
  body: []
  paper_title: "Foo"
  role: "admin"
  phase_id: null
  paper_id: null
  lite_paper_id: null
  assignee_ids: []
  participant_ids: []
  comment_ids: []

ETahi.FactoryAttributes.FinancialDisclosureTask =
  _rootKey: 'task'
  body: []
  comment_ids: []
  completed: false
  funder_ids: []
  id: null
  lite_paper_id: null
  paper_id: null
  paper_title: "Test"
  participation_ids: []
  phase_id: null
  question_ids: []
  role: "author"
  title: "Financial Disclosure"
  type: "StandardTasks::FinancialDisclosureTask"

ETahi.FactoryAttributes.Funder =
  _rootKey: 'funder'
  author_ids: []
  funder_had_influence: false
  funder_influence_description: null
  grant_number: null
  id: null
  name: "Monsanto"
  task_id: null
  website: "www.monsanto.com"
ETahi.FactoryAttributes.Comment =
  _rootKey: 'comment'
  id: null
  commenter_id: null
  task_id: null
  body: "A sample comment"
  created_at: null
  comment_look_ids: []

ETahi.FactoryAttributes.CommentLook =
  _rootKey: 'comment_look'
  id: null
  read_at: null
  comment_id: null
  user_id: null

ETahi.FactoryAttributes.Phase =
  _rootKey: 'phase'
  id: null
  name: "Submission Data"
  position: null
  paper_id: null
  tasks: []

ETahi.FactoryAttributes.ManuscriptManagerTemplate =
  _rootKey: 'manuscript_manager_template'
  id: null
  paper_type: "Research"
  phase_template_ids: []
  journal_id: null

ETahi.FactoryAttributes.PhaseTemplate =
  _rootKey: 'phase_template'
  id: null
  position: 1
  manuscript_manager_template_id: null
  name: "Phase 1"
  task_template_ids: []

ETahi.FactoryAttributes.JournalTaskType =
  _rootKey: 'journal_task_type'
  id: null
  task_type_id: null
  title: null
  journal_id: null
  role: null

ETahi.FactoryAttributes.TaskType =
  _rootKey: 'task_type'
  id: null
  kind: "Task"

ETahi.FactoryAttributes.Participation =
  _rootKey: 'participation'
  id: null
  task: null
  participant_id: null
