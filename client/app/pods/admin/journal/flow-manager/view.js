import Ember from 'ember';
import Utils from 'tahi/services/utils';

export default Ember.View.extend({
  columnCountDidChange: function() {
    Ember.run.scheduleOnce('afterRender', this, Utils.resizeColumnHeaders);
  }.on('didInsertElement').observes('controller.model.flows.[]')
});
