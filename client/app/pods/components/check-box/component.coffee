`import Ember from 'ember'`

CheckBoxComponent = Ember.Component.extend
  classNames: ["ember-checkbox"]
  tagName: "input"
  attributeBindings: "type checked indeterminate disabled tabindex name autofocus form value".w()

  type: "checkbox"
  checked: false
  disabled: false
  indeterminate: false

  init: ->
    @_super()
    @on "change", this, @_updateElementValue

  didInsertElement: ->
    @_super()
    @get("element").indeterminate = !!@get("indeterminate")

  _updateElementValue: ->
    @set("checked", @$().prop("checked"))

  change: ->
    @sendAction('action', @)

`export default CheckBoxComponent`
