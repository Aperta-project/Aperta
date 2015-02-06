`import Ember from 'ember'`

UserThumbnail = Ember.Handlebars.makeBoundHelper (user) ->
  url  = user.get('avatarUrl')
  name = user.get('name')
  new Handlebars.SafeString "<img alt='#{name}' class='user-thumbnail' src='#{url}' data-toggle='tooltip' title='#{name}' />"

`export default UserThumbnail`
