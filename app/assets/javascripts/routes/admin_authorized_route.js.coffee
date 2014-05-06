ETahi.AdminAuthorizedRoute = Ember.Route.extend
  beforeModel: (transition) ->
    @handleUnauthorizedRequest(transition) unless Tahi.currentUser.admin

  handleUnauthorizedRequest: (transition) ->
    transition.abort()
    @transitionTo 'index'

  events:
    error: (response, transition) ->
      switch response.status
        when 403 then @handleUnauthorizedRequest(transition)
