`import Ember from 'ember'`

DashboardLinkView = Ember.View.extend
  templateName: 'dashboard-link'

  paperId: Ember.computed.alias('content.id')

  linkIdentifier: (->
    @get('content.doi') || @get('content.id')
  ).property('content.id', 'content.doi')

  unreadCommentsList: Ember.computed 'unreadComments.@each.readAt', 'unreadComments.@each.paperId', ->
    paperId = @get('paperId')
    @get('unreadComments').filter (c) -> c.get('paperId') == paperId && !c.get('readAt')

  unreadCommentsCount: (->
    @get('unreadCommentsList.length')
  ).property('unreadCommentsList.length')

  refreshTooltips: ->
    # EMBERCLI TODO - tooltips
    # Ember.run.scheduleOnce 'afterRender', @, =>
    #   if @$()
    #     @$('.link-tooltip').tooltip('destroy').tooltip({placement: 'bottom'})

  setupTooltips: (->
    @addObserver('content.unreadCommentsCount', @, @refreshTooltips)
    @refreshTooltips()
  ).on('didInsertElement')

  teardownTooltips: (->
    @removeObserver('content.unreadCommentsCount', @, @refreshTooltips)
  ).on('willRemoveElement')

  badgeTitle: (->
    "#{@get('content.unreadCommentsCount')} new posts"
  ).property('content.unreadCommentsCount')

`export default DashboardLinkView`
