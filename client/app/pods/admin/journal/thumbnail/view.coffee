`import Ember from 'ember'`

JournalThumbnailView = Ember.View.extend
  togglePreview: (->
    Ember.run.schedule 'afterRender', =>
      if @get('controller.logoPreview')
        @$('.journal-logo-preview').empty().append(@get('controller.logoPreview'))
      else
        @$('.journal-logo-preview').html('')
  ).observes('controller.logoPreview')

 `export default JournalThumbnailView`
