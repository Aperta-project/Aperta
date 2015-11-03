import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, Discussions,  {
  actions: {
    viewCard: function(task) {
      this.send('viewVersionedCard',
                task,
                this.get('viewingVersion.major_version'),
                this.get('viewingVersion.minor_version'));
    },

    setViewingVersion(version) {
      this.set('viewingVersion', version);
    },

    setComparisonVersion(version) {
      this.set('comparisonVersion', version);
    }
  }
});
