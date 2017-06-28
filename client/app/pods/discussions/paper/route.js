import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.query('paper',{shortDoi: params.paper_shortDoi})
      .then((results) => {
        let paper = results.get('firstObject');
        paper.atMentionableStaffUsers();
        return paper;
      });
  },
});
