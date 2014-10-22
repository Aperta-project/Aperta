ETahi.ParticipantSelectorComponent = Ember.Component.extend
  resultsTemplate: (user) ->
    '<strong>' + user.full_name + '</strong><br><div class="tt-suggestion-sub-value">' + user.info + '</div>'

  selectedTemplate: (user) =>
    '<img src=\"' + user.avatar_url + '\" class="user-thumbnail"/>'

  remoteSource: (->
    url: "/filtered_users/non_participants/#{@get('taskId')}/"
    dataType: "json"
    data: (term) ->
      query: term
    results: (data) ->
      results: data
  ).property()


  actions:
    addParticipant: (newParticipant) ->
      @sendAction("onSelect", newParticipant.id)
    removeParticipant: (participant) ->
      @sendAction("onRemove", participant)
