ETahi.AdminAuthorizedRoute = Ember.Route.extend
  beforeModel: (transition) ->
    @handleUnauthorizedRequest(transition) unless @getCurrentUser? and @getCurrentUser().get('admin')

  handleUnauthorizedRequest: (transition) ->
    transition.abort()
    @transitionTo 'index'

  actions:
    error: (response, transition) ->
      switch response.status
        when 403 then @handleUnauthorizedRequest(transition)
