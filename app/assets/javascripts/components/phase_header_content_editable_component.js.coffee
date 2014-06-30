ETahi.PhaseHeaderContentEditableComponent = ETahi.ContentEditableComponent.extend
  valueDidChange: (->
    @setHTMLFromValue() if @get('value')
  ).observes('value')
