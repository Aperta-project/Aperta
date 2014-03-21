ETahi.MessageTaskView = Ember.View.extend
  templateName: 'overlays/message'
  layoutName: 'layouts/assignee_layout'

  didInsertElement: ->
    $('.user-thumbnail').tooltip(placement: 'bottom')
