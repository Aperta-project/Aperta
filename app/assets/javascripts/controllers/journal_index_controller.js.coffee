ETahi.JournalIndexController = Ember.ObjectController.extend
  saveStatus: ''

  actions:
    saveCss: ->
      @get('model').save()
      @set('saveStatus', 'Saved')
