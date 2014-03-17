ETahi.CardLinkComponent = Ember.Component.extend
  taskHref:( ->
    "#/papers/#{@get('paper.id')}/tasks/#{@get('task.id')}"
  ).property('paper.id', 'task.id')
