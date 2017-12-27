import TaskComponent from 'tahi/pods/components/task-base/component';
import Ember from 'ember';

const { computed, observer, on } = Ember;
const { alias } = computed;

export default TaskComponent.extend({
  funders: alias('task.funders'),
  paper: alias('task.paper'),
  receivedFunding: null,

  nestedQuestionsForNewFunder: Ember.A(),

  newFunderQuestions: on('init', function(){
    const queryParams = { type: 'Funder' };
    const results = this.get('store').query('nested-question', queryParams);

    results.then( (nestedQuestions) => {
      this.set('nestedQuestionsForNewFunder', nestedQuestions);
    });
  }),

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
      return this.get('store').createRecord('funder', {
        nestedQuestions: this.get('nestedQuestionsForNewFunder'),
        task: this.get('task')
      }).save();
    }
  }
});
