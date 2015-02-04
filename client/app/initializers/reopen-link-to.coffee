`import Ember from 'ember'`

ReopenLinkTo =
  name: 'reopenLinkTo'

  initialize: (container, application) ->
    Ember.LinkView.reopen
      attributeBindings: ['data-toggle', 'data-placement', 'title']

`export default ReopenLinkTo`
