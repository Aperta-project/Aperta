/**
 * This file functions as a grab bag of routes.
 * Eventually we might want to refactor this into an object but
 * for now top-level functions will do just fine.
 */
export function eligibleUsersPath(taskId, userType) {
  return `api/tasks/${taskId}/eligible_users/${userType}`;
}

export function uploadManuscriptPath(taskId) {
  return `api/tasks/${taskId}/upload_manuscript`;
}

export function filteredUsersPath(paperId) {
  return `/api/filtered_users/users/${paperId}`;
}

export function discussionUsersPath(topicId) {
  return `/api/discussion_topics/${topicId}/users`;
}
