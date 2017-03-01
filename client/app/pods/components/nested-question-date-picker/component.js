import CardContentQuestion from
  'tahi/pods/components/card-content-question/component';

export default CardContentQuestion.extend({
  actions: {
    dateChanged: function(newDate){
      this.set('answer.value', newDate);
    }
  }
});
