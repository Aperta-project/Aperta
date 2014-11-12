ETahi.Select2SingleComponent = ETahi.Select2Component.extend
  setSelectedData: (->
    @.$().select2('val', @get('selectedData'))
  ).observes('selectedData')

  initSelection: (el, callback) ->
    callback(@get('selectedData'))
