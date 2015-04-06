`import Ember from 'ember'`

FunderView = Ember.View.extend
  templateName: 'tahi_standard_tasks/funder'

  change: (e) ->
    @get('controller').send('funderDidChange')

`export default FunderView`
