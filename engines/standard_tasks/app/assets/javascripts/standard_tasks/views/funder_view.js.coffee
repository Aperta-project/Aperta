ETahi.FunderView = Ember.View.extend
  templateName: 'standard_tasks/funder'

  change: (e) ->
    @get('controller').send('funderDidChange')
