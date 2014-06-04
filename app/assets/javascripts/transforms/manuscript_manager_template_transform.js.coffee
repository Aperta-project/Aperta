ETahi.ManuscriptManagerTemplateTransform = DS.Transform.extend
  deserialize: (value) ->
    value ||= []
    value.map (templateModel) ->
      ETahi.ManuscriptManagerTemplate.create(templateModel)

  serialize: (value) ->
    # We are returning an empty array here because we want to save
    # attributes on the journal.
    #
    # throw new Error("We shouldn't try to save MMTs with a journal")
    []
