`import Ember from 'ember'`

TimeAgoComponent = Ember.Component.extend
  tagName: 'span'
  classNameBindings: [':time-ago', 'time::hidden']
  attributeBindings: ['title']

  didInsertElement: (->
    @$().timeago()
  )

  title: (->
    @get('time')?.toISOString()
  ).property('time')

  displayTime: (->
    Ember.run.schedule('afterRender', =>
      @$().timeago('updateFromDOM')
    )
  ).observes('title')


`export default TimeAgoComponent`
