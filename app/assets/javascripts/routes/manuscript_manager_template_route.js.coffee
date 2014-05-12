ETahi.ManuscriptManagerTemplateRoute = ETahi.AdminAuthorizedRoute.extend
  model: (params) ->
    @modelFor('journal').then (journal) ->
      journal.get('manuscriptManagerTemplates').map (templateModel) ->
        ETahi.ManuscriptManagerTemplate.create(templateModel)
