import hbs from 'htmlbars-inline-precompile';
import sinon from 'sinon';
import { manualSetup, make } from 'ember-data-factory-guy';
import { moduleForComponent, test } from 'ember-qunit';

moduleForComponent('reviewer-report-status', 'Integration | Component | reviewer report status', {
  integration: true,
  beforeEach() {
    manualSetup(this.container);
    this.set('reviewerReport', make('reviewer-report'));
    this.set('canEditDueDate', true);
  }
});

let template = hbs`{{reviewer-report-status
                      report=reviewerReport
                      canEditDueDate=canEditDueDate
                      uiState='closed'}}`;

test('should save due-datetime on date selection', function(assert){
  let spy = sinon.spy();
  let dueDatetime = make('due-datetime', { save: spy });
  this.set('reviewerReport.dueDatetime', dueDatetime);
  this.render(template);

  this.$('.date-picker-link').click();
  this.$('.datepicker').datepicker('setDate', '10/12/2020');

  assert.equal(spy.called, true, 'dueDatetime.save called');
});
