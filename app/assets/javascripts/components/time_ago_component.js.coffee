ETahi.TimeAgoComponent = Ember.Component.extend
  tagName: 'span'
  classNames: 'time-ago'
  attributeBindings: ['title']

  didInsertElement: (->
    @$().timeago()
  )

  title: (->
    @get('time')?.toISOString()
  ).property('time')

  displayTime: (->
    if @get('title')
      Ember.run.schedule('afterRender', =>
        @$().timeago('updateFromDOM')
      )
  ).observes('title')
