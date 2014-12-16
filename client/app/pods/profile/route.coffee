`import Ember from 'ember'`

ProfileRoute = Ember.Route.extend
  model: ->
    @currentUser

  afterModel: (model) ->
    Ember.$.getJSON('/affiliations', (data)->
      model.set('institutions', data.institutions)
    )

  actions:
    willTransition: (transition) ->
      controller = @controllerFor('profile')

      if controller.get 'isUploading'
        if confirm 'You are uploading, are you sure you want to cancel?'
          controller.send 'cancelUploads'
        else
          transition.abort()
          return
      else
        true

`export default ProfileRoute`
