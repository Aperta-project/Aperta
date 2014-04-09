ETahi.CardView = Em.View.extend(DragNDrop.Dragable, {
  templateName: 'card'
  classNames: ['card']
  classNameBindings: ['completed', 'isMessage']

  setupTooltip: (->
    @.$().find('.remove-card').tooltip()
  ).on('didInsertElement')

  completed: (->
    if @get('content.completed') then 'card-completed' else false
  ).property('content.completed')

  isMessage: (->
    if @get('content.isMessage') then 'card-message' else false
  ).property('content.isMessage')
})
