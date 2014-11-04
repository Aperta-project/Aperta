ETahi.Select2SingleComponent = Ember.TextField.extend
  setSelectedData: (->
    @.$().select2('val', @get('selectedData'))
  ).observes('selectedData')
