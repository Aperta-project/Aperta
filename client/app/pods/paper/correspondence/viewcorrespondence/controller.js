import Ember from 'ember';

export default Ember.Controller.extend({
  title: Ember.computed('model.status', function() {
    return this.get('model.status') === 'deleted' ? 'Deleted Record' : 'Correspondence Record';
  }),

  actions: {
    hideCorrespondenceOverlay() {
      this.send('removeCorrespondenceOverlay');
    }
  }
});
