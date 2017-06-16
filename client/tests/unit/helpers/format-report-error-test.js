
import { formatReportError } from 'tahi/helpers/format-report-error';
import { module, test } from 'qunit';

module('Unit | Helper | format report error');

test('prefaces report error text to the system generated error', function(assert) {
  let message = Ember.Object.create({
    text: 'Some error has occurred.'
  });
  let result = formatReportError([message]);
  assert.deepEqual(result.text,
    '<strong>Report not available:</strong> Some error has occurred. <br>Click below to try again. If you continue to experience problems generating a report, please contact support.',
    "Should prepend 'Report not Available' helper text");
});
