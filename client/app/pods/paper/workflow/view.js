import Ember from 'ember';
import Utils from 'tahi/services/utils';

export default Ember.View.extend({
  setupColumnHeights: function() {
    Ember.run.scheduleOnce('afterRender', this, Utils.resizeColumnHeaders);
  }.on('didInsertElement').observes('controller.phases.[]')
});
