import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['attachment-snapshot'],
  classNameBindings: ['added', 'attachment1::removed'],
  attachment1: null,
  attachment2: null,

  added: Ember.computed('attachment2', function() {
    // gotta check if the whole thing was deleted, not just absent
    // because we're viewing a single version.
    return !this.get('attachment2') || _.isEmpty(this.get('attachment2'));
  }),

  fileHashChanged: Ember.computed(
    'attachment1.fileHash',
    'attachment2.fileHash',

    function() {
      var hash1 = this.get('attachment1.fileHash');
      var hash2 = this.get('attachment2.fileHash');
      return hash1 !== hash2;
    }
  )
});
