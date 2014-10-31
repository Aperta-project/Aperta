ETahi.SelectedYesContentComponent = Ember.Component.extend
  layoutName: 'components/show-if-content'
  showContent: Em.computed.alias 'parentView.selectedYes'
