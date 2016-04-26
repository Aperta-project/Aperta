export function eligibleUsersPath(taskId, userType) {
  return `api/tasks/${taskId}/eligible_users/${userType}`;
}
