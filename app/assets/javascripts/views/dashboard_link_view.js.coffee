ETahi.DashboardLinkView = Em.View.extend
  templateName: 'dashboard_link'

  setupTooltips: (->
    @$('.link-tooltip').tooltip('destroy').tooltip({placement: 'bottom'})
  ).on('didInsertElement').observes('content.unreadCommentsCount')

  badgeTitle: (->
    "#{@get('content.unreadCommentsCount')} new posts"
  ).property('content.unreadCommentsCount')
