Ember.Handlebars.helper 'userThumbnail', (user) ->
  imageUrl = user.get('imageUrl')
  name = user.get('name')
  new Handlebars.SafeString "<img alt='#{name}' class='user-thumbnail' src='#{imageUrl}' data-toggle='tooltip' title='#{name}' />"
