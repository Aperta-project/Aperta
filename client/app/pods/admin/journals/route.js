import Ember from 'ember';

export default Ember.Route.extend({
  model(params) {
    return this.store.findAll('admin-journal').then((journals) => {
      let journal = journals.find(j => j.id === params.journal_id);
      // For users with only one journal, transition to 
      // that journal rather than 'all journals'.
      if (!journal && journals.get('length') === 1) {
        journal = journals.get('firstObject');
      }

      return {
        journals: journals,
        journal: journal
      };
    });
  }
});
