ETahi.CardItemView = Em.View.extend(DragNDrop.Dragable, {
  tagName: 'li'
  templateName: 'card-item'
  classNames: ['card-item']

  setupTooltip: (->
    @.$().find('.remove-card').tooltip()
  ).on('didInsertElement')
})
