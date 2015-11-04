import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, Discussions,  {
  queryParams: ['majorVersion', 'minorVersion'],

  actions: {
    viewCard: function(task) {
      this.send('viewVersionedCard',
                task,
                this.get('majorVersion'),
                this.get('minorVersion'));
    },

    setViewingVersion(version) {
      this.set('viewingVersion', version);
      this.set('majorVersion', version.get('majorVersion'));
      this.set('minorVersion', version.get('minorVersion'));
    },

    setComparisonVersion(version) {
      this.set('comparisonVersion', version);
      // this.set('majorVersion', version.majorVersion);
      // this.set('minorVersion', version.minorVersion);
    }
  }
});
