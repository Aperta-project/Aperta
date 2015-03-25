`import Ember from 'ember'`

FunderView = Ember.View.extend
  templateName: 'standard_tasks/funder'

  change: (e) ->
    @get('controller').send('funderDidChange')

`export default FunderView`
