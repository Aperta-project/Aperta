import Ember from 'ember';

export default Ember.Mixin.create({
  classNameBindings: ['QAIdent'],

  QAIdent: Ember.computed('content.ident', function() {
    const ident = this.get('content.ident');
    if (ident) {
      return `qa-ident-${ident}`.replace(/[^a-z_-]/g, '_');
    } else {
      return undefined;
    }
  })
});
