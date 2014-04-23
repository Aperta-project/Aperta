ETahi.ManuscriptManagerTemplateNewRoute = Ember.Route.extend
  model: (params) ->
    paperTypes = @modelFor('journal').get('paperTypes')
    newTemplate = ETahi.ManuscriptManagerTemplate.create(
      name: "New Template"
      paper_type: paperTypes.get('firstObject')
      template:
        phases: [
          name: "New Phase"
          task_types: []
        ]
    )
    @modelFor('manuscriptManagerTemplate').pushObject(newTemplate)


