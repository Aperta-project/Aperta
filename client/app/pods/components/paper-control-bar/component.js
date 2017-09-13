import Ember from 'ember';
import ControlBar from 'tahi/pods/components/control-bar/component';
import { PropTypes } from 'ember-prop-types';

const { computed } = Ember;

export default ControlBar.extend({
  propTypes: {
    contributorsVisible: PropTypes.bool,
    versionsVisible: PropTypes.bool,
    versioningMode: PropTypes.bool,
    submenuVisible: PropTypes.bool,
    toggleDownloads: PropTypes.func,
    showActivity: PropTypes.func
  },

  getDefaultProps() {
    return {
      contributorsVisible: false,
      submenuVisible: false,
      versionsVisible: false,
      versioningMode: false
    };
  },

  paperWithdrawn: computed.equal('paper.publishingState', 'withdrawn'),

  resetSubmenuFlags() {
    this.setProperties({
      contributorsVisible: false,
      versionsVisible: false
    });
  },

  showSection(sectionName) {
    this.resetSubmenuFlags();
    this.set('submenuVisible', true);
    this.set(`${sectionName}Visible`, true);
  },

  actions: {
    showSubNav(sectionName) {
      if (this.get('submenuVisible') && this.get(`${sectionName}Visible`)) {
        this.resetSubmenuFlags();
        this.set('submenuVisible', false);
        this.get('transitionToPaperIndex')();
      } else {
        this.showSection(sectionName);
      }
    },

    toggleVersioningMode() {
      this.toggleProperty('paper.versioningMode');
      this.send('showSubNav', 'versions');
    },

    addContributors(activity) {
      this.sendAction('addContributors', activity);
    },

    toggleDownloads() {
      this.get('toggleDownloads')();
    },

    withdrawManuscript() {
      this.sendAction('showWithdrawOverlay');
    }
  }
});
