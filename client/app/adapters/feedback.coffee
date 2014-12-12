`import DS from 'ember-data'`

FeedbackAdapter = DS.ActiveModelAdapter.extend
  pathForType: (type) ->
    'feedback'

`export default FeedbackAdapter`
