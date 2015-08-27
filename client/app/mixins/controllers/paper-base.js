import Ember from 'ember';
import DocumentDownload from 'tahi/services/document-download';
import ENV from 'tahi/config/environment';

const { computed } = Ember;

export default Ember.Mixin.create({
  needs: ['application', 'paper'],
  isAdmin: Ember.computed.alias('currentUser.siteAdmin'),
  canViewManuscriptManager: false,

  supportedDownloadFormats: computed(function() {
    return ENV.APP.iHatExportFormats.map(formatType => {
      return {format: formatType, icon: `svg/${formatType}-icon`};
    });
  }),

  pageContainerHTMLClass: computed('model.editorMode', function() {
    return 'paper-container-' + this.get('model.editorMode');
  }),

  // Tasks:

  currentUserTasks: computed.filter('model.tasks', function(task) {
    return task.get('participations').mapBy('user').contains(this.get('currentUser'));
  }),

  metadataTasks: computed.filterBy('model.tasks', 'isMetadataTask', true),
  assignedTasks: computed.setDiff('currentUserTasks', 'metadataTasks'),

  noTasks: computed('assignedTasks.@each', 'metadataTasks.@each', function() {
    return [this.get('assignedTasks'), this.get('metadataTasks')].every((taskGroup)=> {
      return Ember.isEmpty(taskGroup);
    });
  }),

  actions: {
    exportDocument(downloadType) {
      return DocumentDownload.initiate(this.get('model.id'), downloadType.format);
    }
  }
});
