`import Ember from 'ember'`

InlineEditView = Ember.View.extend
  templateName: 'inline-edit'
  isTextItem: Ember.computed.equal 'item.type', 'text'
  isCheckboxItem: Ember.computed.equal 'item.type', 'checkbox'
  isEmailItem: Ember.computed.equal 'item.type', 'email'
  editing: Ember.computed.alias 'parentView.editing'
  isSendable: true

`export default InlineEditView`
