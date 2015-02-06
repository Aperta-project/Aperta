`import Ember from 'ember'`

ProfileRoute = Ember.Route.extend
  model: ->
    @currentUser

  afterModel: (model) ->
    Ember.$.getJSON('/affiliations', (data)->
      model.set('institutions', data.institutions)
    )

`export default ProfileRoute`
