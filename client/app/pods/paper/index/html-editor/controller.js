import Ember from 'ember';
import PaperBase from 'tahi/mixins/controllers/paper-base';
import PaperIndex from 'tahi/mixins/controllers/paper-index';
import Discussions from 'tahi/mixins/discussions/route-paths';

export default Ember.Controller.extend(PaperBase, PaperIndex, Discussions, {
  subRouteName: 'index',

  // JERRY: ?
  hasOverlay: false,

  versioningMode: false
});
