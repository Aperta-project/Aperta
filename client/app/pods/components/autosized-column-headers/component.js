import Ember from 'ember';
import resizeColumnHeaders from 'tahi/lib/resize-column-headers';

export default Ember.Component.extend({
  classNames: ['columns'],
  columns: null, //passed in
  setupColumnHeights: function() {
    Ember.run.scheduleOnce('afterRender', this, resizeColumnHeaders);
  }.on('didInsertElement').observes('columns.[]')
});
