import Ember from 'ember';
import listCardContentComponent from 'tahi/mixins/components/list-card-content-component';

export default Ember.Component.extend(listCardContentComponent, {
  classNames: ['card-content-numbered-list'],
  tagName: 'ol',
  attributeBindings:['type'],
  type: '1',
});
