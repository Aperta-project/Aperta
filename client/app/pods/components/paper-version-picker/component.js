import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';

export default Ember.Component.extend(PaperBase, {
  elementId: 'versioning-bar',
  classNames: ['versions', 'active'],

  versionsContainPDF: false,

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
