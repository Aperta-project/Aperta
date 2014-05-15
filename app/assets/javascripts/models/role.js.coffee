ETahi.Role = DS.Model.extend
  name: DS.attr('string')
  admin: DS.attr('boolean')
  editor: DS.attr('boolean')
  reviewer: DS.attr('boolean')
  isBuiltIn: Ember.computed.or('admin', 'editor', 'reviewer')
