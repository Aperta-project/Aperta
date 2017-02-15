import Ember from 'ember';

export default Ember.Component.extend({
  classNames: ['source-link'],

  sourceIcon: Ember.computed('version', function() {
     const icons = { 
       'docx': "file-word-o",
       'doc': "file-word-o",
       'zip': "file-zip-o",
       'tex': "file-text-o"
     };
    return icons[this.get('version.sourceType')];
  }),

  sourceName: Ember.computed('version', function() {
    const names = {
      'docx' : 'Word',
      'doc' : 'Word',
      'zip' : 'Zip',
      'tex' : 'Latex'
    };
    return names[this.get('version.sourceType')];
  })

});
