import Ember from 'ember';
import fontAwesomeFiletypeClass from 'tahi/lib/font-awesome-fyletype-class';

export default Ember.Component.extend({
  fileTypeClass: Ember.computed('attachment.file', function(){
    return fontAwesomeFiletypeClass(this.get('attachment.file'));
  })
});
