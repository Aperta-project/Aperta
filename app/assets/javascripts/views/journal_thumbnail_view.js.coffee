ETahi.JournalThumbnailView = Ember.View.extend
  isHovering: false
  mouseEnter: -> @set('isHovering', true)
  mouseLeave: -> @set('isHovering', false)
