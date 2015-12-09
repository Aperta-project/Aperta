import Ember from 'ember';
import Participants from 'tahi/mixins/controllers/participants';

export default Ember.Controller.extend(Participants, {
  actions: {
    close() {
      this.transitionToRoute('paper', this.get('model.paper'));
    }
  }
});
