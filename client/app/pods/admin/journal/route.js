import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findAll('admin-journal').then((journals) => {
      var journal = journals.find(j => j.id === params.journal_id);
      if (!journal && !params.journal_id) { 
        journal = journals.get('firstObject');
      }
      return {
        journals: journals,
        journal: journal
      };
    });
  }

});
