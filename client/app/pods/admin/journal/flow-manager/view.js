import Ember from 'ember';
import resizeColumnHeaders from 'tahi/lib/resize-column-headers';

export default Ember.View.extend({
  columnCountDidChange: function() {
    Ember.run.scheduleOnce('afterRender', this, resizeColumnHeaders);
  }.on('didInsertElement').observes('controller.model.flows.[]')
});
