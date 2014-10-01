ETahi.DashboardLinkView = Em.View.extend
  templateName: 'dashboard_link'

  refreshTooltips: ->
    Ember.run.scheduleOnce 'afterRender', @, =>
      if @$()
        @$('.link-tooltip').tooltip('destroy').tooltip({placement: 'bottom'})

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
