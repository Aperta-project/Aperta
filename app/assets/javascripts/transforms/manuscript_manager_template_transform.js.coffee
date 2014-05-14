ETahi.ManuscriptManagerTemplateTransform = DS.Transform.extend
  deserialize: (value) ->
    value ||= []
    value.map (templateModel) ->
      ETahi.ManuscriptManagerTemplate.create(templateModel)

  serialize: (value) ->
    throw new Error("We shouldn't try to save MMTs with a journal")

