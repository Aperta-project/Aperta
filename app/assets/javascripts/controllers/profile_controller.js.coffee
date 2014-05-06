ETahi.ProfileController = Ember.ObjectController.extend
  hideAffiliationForm: true

  actions:
    toggleAffiliationForm: ->
      @set('hideAffiliationForm', !@hideAffiliationForm)

