import Ember from 'ember';

export default Ember.Component.extend({
  completedStage: null,

  stages: Ember.computed('completedStage', function() {
    let completedStage = this.get('completedStage');
    Ember.assert(
      'you must pass a stage between 0 and 3',
      completedStage >= 0 && completedStage < 4
    );
    return [1, 2, 3].map((i) => {
      let isComplete = (i <= completedStage);
      return {complete: isComplete, number: i};
    });
  })

});
