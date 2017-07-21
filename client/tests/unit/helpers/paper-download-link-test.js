import { paperDownloadLink } from 'tahi/helpers/paper-download-link';
import { module, test } from 'qunit';
import Ember from 'ember';

module('Unit | Helper | paper download link');

test('renders a paper download link', function(assert) {
  const paperVersion = Ember.Object.create({
    id: 1,
    paper: {
      id: 2
    }
  });
  const format = 'pdf';
  let result = paperDownloadLink([], {paperVersion, format});
  assert.equal(result, '/api/paper_downloads/2?export_format=pdf&paper_version_id=1');
});
