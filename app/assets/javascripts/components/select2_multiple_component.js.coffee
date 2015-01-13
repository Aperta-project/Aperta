ETahi.Select2MultipleComponent = ETahi.Select2Component.extend
  multiSelect: true

  setSelectedData: (->
    @.$().select2('val', (@get('selectedData') || []).mapProperty('id'))
  ).observes('selectedData')

