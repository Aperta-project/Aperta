`import Ember from 'ember'`
`import SpinnerMixin from 'tahi/mixins/views/spinner'`

JournalThumbnailView = Ember.View.extend SpinnerMixin,
  toggleSpinner: (->
    @createSpinner('controller.isUploading', '.journal-logo-spinner', color: '#fff')
  ).observes('controller.isUploading').on('didInsertElement')

  togglePreview: (->
    Ember.run.schedule 'afterRender', =>
      if @get('controller.logoPreview')
        @$('.journal-logo-preview').empty().append(@get('controller.logoPreview'))
      else
        @$('.journal-logo-preview').html('')
  ).observes('controller.logoPreview')

 `export default JournalThumbnailView`
