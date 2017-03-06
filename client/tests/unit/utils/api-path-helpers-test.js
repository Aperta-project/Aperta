import { paperDownloadPath } from 'tahi/utils/api-path-helpers';
import { module, test } from 'qunit';

module('Unit | Utility | api path helpers');

test('paperDownloadPath', function(assert) {
  const opts = {
    paperId: 1,
    versionedTextId: 2,
    format: 'pdf'
  };
  assert.equal(
    paperDownloadPath(opts),
    '/api/paper_downloads/1?export_format=pdf&versioned_text_id=2'
  );
});

test('paperDownloadPath', function(assert) {
  const opts = {
    paperId: 1,
    format: 'pdf'
  };
  assert.equal(
    paperDownloadPath(opts),
    '/api/paper_downloads/1?export_format=pdf'
  );
});

