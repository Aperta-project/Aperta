import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, Discussions,  {
  queryParams: ['selectedVersion1', 'selectedVersion2'],

  actions: {
    viewCard: function(task) {
      this.send('viewVersionedCard',
                task,
                this.selectedVersion1,
                this.selectedVersion2);
    },

    setViewingVersion(version) {
      this.set('viewingVersion', version);
      this.set('selectedVersion1', `${version.get('majorVersion')}.${version.get('minorVersion')}`);
    },

    setComparisonVersion(version) {
      this.set('comparisonVersion', version);
      this.set('selectedVersion2', `${version.get('majorVersion')}.${version.get('minorVersion')}`);
    }
  }
});
