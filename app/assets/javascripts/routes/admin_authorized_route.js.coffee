ETahi.AuthorizedRoute = Ember.Route.extend
  handleUnauthorizedRequest: (transition) ->
    transition.abort()
    @transitionTo 'index'

  actions:
    error: (response, transition) ->
      switch response.status
        when 403 then @handleUnauthorizedRequest(transition)
      console.log "Error in transition to #{transition.targetName}"
      true # bubble for other error handling
