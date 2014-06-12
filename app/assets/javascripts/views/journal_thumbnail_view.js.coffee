ETahi.JournalThumbnailView = Ember.View.extend
  templateName: 'journal/journal_thumbnail'
  isHovering: false
  mouseEnter: -> @set('isHovering', true)
  mouseLeave: -> @set('isHovering', false)
