import Ember from 'ember';

export default Ember.Controller.extend({
  overlayClass: 'overlay--fullscreen choose-new-card-type-overlay',
  taskTypeSort: ['title:asc'],
  sortedTaskTypes: Ember.computed.sort('journalTaskTypes', 'taskTypeSort'),
});
