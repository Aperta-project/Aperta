ETahi.ProfileController = Ember.ObjectController.extend
  newAffiliation: {}
  hideAffiliationForm: true

  actions:
    toggleAffiliationForm: ->
      @set('hideAffiliationForm', !@hideAffiliationForm)

    createAffiliation: ->
      affiliation = @store.createRecord('affiliation', @newAffiliation)
      affiliation.save().then (affiliation) ->
        affiliation.get('user.affiliations').pushObject(affiliation)
      @set('newAffiliation', {})
      @send('toggleAffiliationForm')
      Ember.run.next @, ->
        $('.datepicker').datepicker('update')

