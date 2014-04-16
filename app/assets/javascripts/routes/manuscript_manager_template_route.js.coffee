ETahi.ManuscriptManagerTemplateRoute = Ember.Route.extend
  model: (params) ->
    journalId = @modelFor('journal').get('id')
    parse_data = (data) -> data.manuscript_manager_templates
    model = new Ember.RSVP.Promise((resolve, reject) -> $.getJSON("/manuscript_manager_templates?journal_id=#{journalId}", resolve).fail(reject))
    model.then(parse_data)
