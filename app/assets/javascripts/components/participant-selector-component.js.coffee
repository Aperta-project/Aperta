ETahi.ParticipantSelectorComponent = Ember.Component.extend
  resultsTemplate: (user) ->
    '<strong>' + user.full_name + '</strong><br><div class="tt-suggestion-sub-value">' + user.info + '</div>'

  selectedTemplate: (user) =>
    name = (user.full_name || user.get('fullName'))
    url  = (user.avatar_url || user.get('avatarUrl'))
    new Handlebars.SafeString "<img alt='#{name}' class='user-thumbnail' src='#{url}' data-toggle='tooltip' title='#{name}'/>"

  sortByCollaboration: (a, b) ->
    if a.info.match(/\,/) && !b.info.match(/\,/)
      -1
    else if !a.info.match(/\,/) && b.info.match(/\,/)
      1
    else
      0

  remoteSource: (->
    url: "/filtered_users/users/#{@get('paperId')}/"
    dataType: "json"
    data: (term) ->
      query: term
    results: (data) =>
      data.sort(@sortByCollaboration)
      results: data
  ).property()

  actions:
    addParticipant: (newParticipant) ->
      @sendAction("onSelect", newParticipant.id)
    removeParticipant: (participant) ->
      @sendAction("onRemove", participant.id)
