import Ember from 'ember';
import fontAwesomeFiletypeClass from 'tahi/lib/font-awesome-fyletype-class';
import fontAwesomeFiletypeText from 'tahi/lib/font-awesome-fyletype-text';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    fileName: PropTypes.string.isRequired
  },

  classNames: ['file-label'],

  fileIcon: Ember.computed('fileName', function() {
    return fontAwesomeFiletypeClass(this.get('fileName')) || 'fa-file-o';
  }),

  fileTypeName: Ember.computed('fileName', function() {
    var filename = this.get('fileName');
    return fontAwesomeFiletypeText(this.get(filename)) || filename.match(/\.([^.]+)$/)[1].toUpperCase();
  })

});
