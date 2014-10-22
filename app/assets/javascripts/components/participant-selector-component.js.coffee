ETahi.ParticipantSelectorComponent = Ember.Component.extend
  resultsTemplate: (user) ->
    '<strong>' + user.full_name + '</strong><br><div class="tt-suggestion-sub-value">' + user.info + '</div>'

  selectedTemplate: (user) =>
    '<img src=\"' + (user.avatar_url || user.get('avatarUrl')) + '\" class="user-thumbnail"/>'

  remoteSource: (->
    url: "/filtered_users/non_participants/#{@get('taskId')}/"
    dataType: "json"
    data: (term) ->
      query: term
    results: (data) ->
      results: data
  ).property()

  availableParticipants: (->
    return [] if Em.isEmpty @get('everyone.content')
    @get('currentParticipants')
  ).property('everyone.content.[]', 'currentParticipants.@each')

  actions:
    addParticipant: (newParticipant) ->
      @sendAction("onSelect", newParticipant.id)
    removeParticipant: (participant) ->
      @sendAction("onRemove", participant)
