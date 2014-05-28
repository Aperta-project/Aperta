ETahi.AdminAuthorizedRoute = Ember.Route.extend
  handleUnauthorizedRequest: (transition) ->
    transition.abort()
    @transitionTo 'index'

  events:
    error: (response, transition) ->
      switch response.status
        when 403 then @handleUnauthorizedRequest(transition)
