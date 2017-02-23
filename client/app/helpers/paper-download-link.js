import Ember from 'ember';
import { paperDownloadPath } from 'tahi/lib/api-path-helpers';

export function paperDownloadLink(_, params) {
  return paperDownloadPath({
    paperId: params.versionedText.get('paper.id'),
    versionedTextId: params.versionedText.get('id'),
    format: params.format
  });
}

export default Ember.Helper.helper(paperDownloadLink);
