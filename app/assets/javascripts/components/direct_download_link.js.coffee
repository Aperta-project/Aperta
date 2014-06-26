ETahi.DirectDownloadLinkComponent = Ember.Component.extend
  downloadLink: (->
    @get('link') + (@get('extension') || '')
  ).property('link')
