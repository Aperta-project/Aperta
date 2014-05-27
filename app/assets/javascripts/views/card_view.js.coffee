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

  updateBadge: ( ->
    content = @get('content')
    if content.get('type') == 'MessageTask'
      Ember.$.getJSON("/activities/message_tasks/#{content.get('id')}/unread_comments_count").then (data) =>
        content.set('unreadCommentsCount', data)
  ).on('didInsertElement')

  dragStart: (e) ->
    e.dataTransfer.setData('Text', 'TAHI!')
    ETahi.set('dragItem', @get('content'))
})
