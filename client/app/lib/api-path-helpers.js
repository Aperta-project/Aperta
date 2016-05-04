export function eligibleUsersPath(taskId, userType) {
  return `api/tasks/${taskId}/eligible_users/${userType}`;
}

export function uploadManuscriptPath(taskId) {
  return `/api/tasks/${taskId}/upload_manuscript`;
}
