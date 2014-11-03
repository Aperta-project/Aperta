ETahi.InlineEditView = Ember.View.extend
  templateName: 'inline-edit'
  isTextItem: Em.computed.equal 'item.type', 'text'
  isCheckboxItem: Em.computed.equal 'item.type', 'checkbox'
  isEmailItem: Em.computed.equal 'item.type', 'email'
  editing: Em.computed.alias 'parentView.editing'
  isSendable: true
