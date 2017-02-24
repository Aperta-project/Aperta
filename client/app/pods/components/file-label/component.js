import Ember from 'ember';
import fontAwesomeFiletypeClass from 'tahi/lib/font-awesome-fyletype-class';
import fontAwesomeFiletypeText from 'tahi/lib/font-awesome-fyletype-text';
import { PropTypes } from 'ember-prop-types';

export default Ember.Component.extend({
  propTypes: {
    fileName: PropTypes.string.isRequired
  },

  classNames: ['source-link'],

  fileIcon: Ember.computed('fileName', function() {
    return fontAwesomeFiletypeClass(this.get('fileName'));
  }),

  fileTypeName: Ember.computed('fileName', function() {
    return fontAwesomeFiletypeText(this.get('fileName'));
  })

});
