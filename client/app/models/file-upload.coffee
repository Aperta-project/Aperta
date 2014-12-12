`import Ember from 'ember'`

FileUpload = Ember.Object.extend

  file: null
  dataLoaded: 0
  dataTotal: 0
  preview: null
  xhr: null

  abort: ->
    @get('xhr')?.abort() # catch me

`export default FileUpload`
