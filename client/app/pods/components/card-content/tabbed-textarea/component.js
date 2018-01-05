import Ember from 'ember';
import QAIdent from 'tahi/mixins/components/qa-ident';

export default Ember.Component.extend(QAIdent, {

  annotation: null,
  instructionText: null,

  didInsertElement() {
    this._super(...arguments);
    // activate bootstrap nav tab elements
    this.$('.nav-tabs > li:first-child').addClass('active');
    this.$('.tab-content > .tab-pane:first-child').addClass('active');
    this.$('.nav-tabs .active').tab('show');

    // resize textarea on initial display and on tab click
    autosize.update(this.$('.tabbed-textarea'));
    $(document).on('shown.bs.tab', function () {autosize.update($('.tabbed-textarea'));});
  }

});
