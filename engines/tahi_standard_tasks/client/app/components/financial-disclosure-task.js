import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

const { computed, observer } = Ember;
const { alias } = computed;

export default TaskComponent.extend({
  funders: alias('task.funders'),
  paper: alias('task.paper'),
  receivedFunding: null,
  numFundersObserver: observer('funders.[]', function() {
    if (this.get('receivedFunding') === false) {
      return;
    }
    if (this.get('funders.length') > 0) {
      this.set('receivedFunding', true);
    } else {
      this.set('receivedFunding', null);
    }
  }),
  actions: {
    choseFundingReceived() {
      this.set('receivedFunding', true);
      if (this.get('funders.length') < 1) {
        return this.send('addFunder');
      }
    },
    choseFundingNotReceived() {
      this.set('receivedFunding', false);
      return this.get('funders').toArray().forEach(function(funder) {
        if (funder.get('isNew')) {
          return funder.deleteRecord();
        } else {
          return funder.destroyRecord();
        }
      });
    },
    addFunder() {
      let store = this.get('store');
      let funderCard = store.peekCard('TahiStandardTasks::Funder');
      let newFunder = store.createRecord('funder', {
        card: funderCard,
        task: this.get('task')
      });
      return newFunder.save();
    }
  }
});
