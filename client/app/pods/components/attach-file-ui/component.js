// This component is meant to wrap a UI pattern that attaches files to
// objects. This particular pattern is a minimal, inline pattern that
// shows no thumbnail
//
// Internally, it uses the file-uploader component, which handles the
// upload to s3, and a postback to rails. The file-uploader component
// sends out various actions as part of its lifecycle. 
//
// This comonent  will either need to catch them and re-emmit them,
// catch them and execute them, or be extended by a mixin that has the
// action block that will catch them
//
// The mixin that has been doing most of the work in our app that has
// these actions is: client/app/mixins/file-upload.js
// but to be honest, this is a mess. I recommend implementing the actions
// below in this component, realizing that this may be duplicating some
// functionality. The truth is that we only really need ONE mixin for
// each set of Functionality (delete, replace, update fields, etc) and
// then we need a UI component for each VISUALLY different 
//
// another file that implements similar actions that catch those sent in
// the file-uploader is pods/components/nested-question-uploader/component.js
// so that can be consulted
//
import FileUpload from 'tahi/models/file-upload';

export default Ember.Component.extend({
  upload: null,
  uploadButtonText: 'upload file',
  getsDescriptionField: true,

  // actions for this ui component
  replace: function() {
  },

  delete: function() {
  },

  update: function() {
  },

  actions: {

    // actions sent by file-upload
    uploadStarted: function(data) {
    },

    uploadProgress: function(data) {
    },

    uploadFinished: function(uploadUrl) {
    },

    destroyAttachment: function(attachment) {
    }
    // ...
  }
});

