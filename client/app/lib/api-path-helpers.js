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
