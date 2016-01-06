import Ember from 'ember';
import resizeColumnHeaders from 'tahi/lib/resize-column-headers';

export default Ember.View.extend({
  setupColumnHeights: function() {
    Ember.run.scheduleOnce('afterRender', this, resizeColumnHeaders);
  }.on('didInsertElement').observes('controller.phases.[]')
});
