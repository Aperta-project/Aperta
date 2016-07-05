import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Component.extend(PaperBase, Discussions, {
 
  actions: {
    setViewingVersion(version) {
      this.set('viewingVersion', version);
      this.set(
        'selectedVersion1',
        `${version.get('majorVersion')}.${version.get('minorVersion')}`);

      this.attrs.setQueryParam(
        'selectedVersion1', this.get('selectedVersion1')
      );
    },

    setComparisonVersion(version) {
      this.set('comparisonVersion', version);
      this.set(
        'selectedVersion2',
        `${version.get('majorVersion')}.${version.get('minorVersion')}`);
      let action = this.get('setQueryParam');
      action('selectedVersion2', this.get('selectedVersion2'));
    }
  }
});
