ETahi.FunderView = Ember.View.extend
  templateName: 'financial_disclosure/funder'

  change: (e) ->
    @get('controller').send('funderDidChange', @get('funder'))
