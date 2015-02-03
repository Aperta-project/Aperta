`import Ember from 'ember'`

DashboardLinkComponent = Ember.Component.extend
  paperId: Ember.computed.alias('model.id')

  linkIdentifier: (->
    @get('model.doi') || @get('model.id')
  ).property('model.id', 'model.doi')

  unreadCommentsList: Ember.computed 'unreadComments.@each.readAt', 'unreadComments.@each.paperId', ->
    paperId = @get('paperId')
    @get('unreadComments').filter (c) -> c.get('paperId') == paperId && !c.get('readAt')

  unreadCommentsCount: (->
    @get('unreadCommentsList.length')
  ).property('unreadCommentsList.length')

  refreshTooltips: ->
    Ember.run.scheduleOnce 'afterRender', @, =>
      if @$()
        @$('.link-tooltip').tooltip('destroy').tooltip({placement: 'bottom'})

  setupTooltips: (->
    @addObserver('model.unreadCommentsCount', @, @refreshTooltips)
    @refreshTooltips()
  ).on('didInsertElement')

  teardownTooltips: (->
    @removeObserver('model.unreadCommentsCount', @, @refreshTooltips)
  ).on('willDestroyElement')

  badgeTitle: (->
    "#{@get('unreadCommentsCount')} new posts"
  ).property('unreadCommentsCount')

`export default DashboardLinkComponent`
