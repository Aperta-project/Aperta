`import Ember from 'ember'`

DirectDownloadLinkComponent = Ember.Component.extend
  downloadLink: (->
    @get('link') + (@get('extension') || '')
  ).property('link')

`export default DirectDownloadLinkComponent`
