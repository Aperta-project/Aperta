ETahi.JournalRoleFlowManagerRoute = Ember.Route.extend
  model: (params) ->
    @store.find('role', params.role_id)

  afterModel: (model) ->
    model.get('flows')
