import Ember from 'ember';
export default Ember.Component.extend({

  isGroup: Ember.computed.alias('mergeField.many'),
  children: Ember.computed.alias('mergeField.children'),
  isLeafNode: Ember.computed.not('children.length'),

  fullName: Ember.computed('mergeField.name', 'prefix', function() {
    let prefix = this.get('prefix');
    let mergeFieldName = this.get('mergeField.name');
    return prefix ? `${prefix}.${mergeFieldName}` : mergeFieldName;
  }),

  itemName: Ember.computed('mergeField.name', 'isGroup', function() {
    let isGroup = this.get('isGroup');
    let mergeFieldName = this.get('mergeField.name');
    let item = null;
    if (isGroup) {
      let inflector = new Ember.Inflector(Ember.Inflector.defaultRules);
      item = inflector.singularize(mergeFieldName);
    }
    return item;
  })
});
