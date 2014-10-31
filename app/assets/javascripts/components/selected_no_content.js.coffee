ETahi.SelectedNoContentComponent = Ember.Component.extend
  layoutName: 'components/show-if-content'
  showContent: Em.computed.alias 'parentView.selectedNo'
