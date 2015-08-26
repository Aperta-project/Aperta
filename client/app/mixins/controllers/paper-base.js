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
  assignedTasks: computed('model.tasks.@each', function() {
    let metadataTasks = this.get('metadataTasks');

    return this.get('model.tasks').filter((task) => {
      return task.get('participations').mapBy('user').contains(this.get('currentUser'));
    }).filter(function(t) {
      return !metadataTasks.contains(t);
    });
  }),

  metadataTasks: Ember.computed.filterBy('model.tasks', 'isMetadataTask', true),

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
