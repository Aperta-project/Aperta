import { module, test } from 'qunit';
import prepper from 'tahi/lib/validations/prepare-response-errors';

module('validations/prepareResponseErrors');

test('with only string details', function(assert) {
  const apiErrors = [
    {
      'detail': 'some error',
      'source': {'pointer': '/path/to/resource'},
      'title': 'title'
    },
    {
      'detail': 'some other error',
      'source': {'pointer': '/path/to/other'},
      'title': 'other title'
    }
  ];

  const errors = prepper(apiErrors, undefined);

  assert.equal(errors['resource'], apiErrors[0]['detail']);
  assert.equal(errors['other'], apiErrors[1]['detail']);
});

test('with an object detail', function(assert) {
  const apiErrors = [
    {
      'detail': {
        1: {'category': ['can`t be blank']}
      },
      'source': {'pointer': '/path/to/resource'},
      'title': 'title'
    },
    {
      'detail': {
        1: {'category': ['can`t be wrong']}
      },
      'source': {'pointer': '/path/to/other'},
      'title': 'other title'
    }
  ];

  const errors = prepper(apiErrors, undefined);

  assert.equal(errors.resource[1], apiErrors[0].detail[1]);
  assert.equal(errors.resource[1], apiErrors[0].detail[1]);
});
