import Ember from 'ember';
import EscapeListenerMixin from 'tahi/mixins/escape-listener';

export default Ember.Component.extend(EscapeListenerMixin, {
  flash: Ember.inject.service(),
  nextStep: null,
  task: Ember.computed('paper.tasks.[]', function() {
    return this.get('paper.tasks').findBy('title', 'Preprint Posting');
  }),

  actions: {
    nextStep() {
      let task = this.get('task');
      const answer = task.get('answers.firstObject.value');
      if (answer === '1') { task.set('completed', true); }

      task.save();
      this.get('nextStep')();
    },

    close(){
      // noop. Closing modal with X or escape after changing a choice would be ambiguous
    }
  }
});
