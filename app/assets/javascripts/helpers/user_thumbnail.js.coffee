Ember.Handlebars.helper 'userThumbnail', (user) ->
  avatarUrl = user.get('avatarUrl')
  name = user.get('name')
  new Handlebars.SafeString "<img alt='#{name}' class='user-thumbnail' src='#{avatarUrl}' data-toggle='tooltip' title='#{name}' />"
