/**
 * This file functions as a grab bag of routes.
 * Eventually we might want to refactor this into an object but
 * for now top-level functions will do just fine.
 */
export function eligibleUsersPath(taskId, userType) {
  return `/api/tasks/${taskId}/eligible_users/${userType}`;
}

export function uploadManuscriptPath(taskId) {
  return `/api/tasks/${taskId}/upload_manuscript`;
}

export function uploadSourceFilePath(taskId) {
  return `/api/tasks/${taskId}/upload_sourcefile`;
}

export function filteredUsersPath(paperId) {
  return `/api/filtered_users/users/${paperId}`;
}

export function discussionUsersPath(topicId) {
  return `/api/discussion_topics/${topicId}/users`;
}

export function newDiscussionUsersPath(paperId) {
  return `/api/papers/${paperId}/discussion_topics/new_discussion_users`;
}

export function paperDownloadPath({paperId, versionedTextId, format}) {
  let path = `/api/paper_downloads/${paperId}`;
  let params = {};
  if (format) {
    params.export_format = format;
  }
  if (versionedTextId) {
    params.versioned_text_id = versionedTextId;
  }
  if (!_.isEmpty(params)) {
    path += `?${$.param(params)}`;
  }
  return path;
}

export function similarityCheckReportPath(similarityCheckId) {
  return `/api/similarity_checks/${similarityCheckId}/report_view_only`;
}
