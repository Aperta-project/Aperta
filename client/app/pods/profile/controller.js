import Ember from 'ember';
import FileUploadMixin from 'tahi/mixins/file-upload';

export default Ember.Controller.extend(FileUploadMixin, {
  errorText: '',
  canRemoveOrcid: true
});
