import Ember from 'ember';
import { paperDownloadPath } from 'tahi/utils/api-path-helpers';

export function paperDownloadLink(_, params) {
  let opts;
  if (params.paper) {
    opts = {
      paperId: params.paper.get('id'),
      format: params.format
    };
  } else if (params.paperVersion) {
    opts = {
      paperId: params.paperVersion.get('paper.id'),
      paperVersionId: params.paperVersion.get('id'),
      format: params.format
    };
  } else {
    throw 'Either paper or paperVersion needs to be defined';
  }

  return paperDownloadPath(opts);
}

export default Ember.Helper.helper(paperDownloadLink);
