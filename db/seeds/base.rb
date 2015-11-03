Paper.create!([
  {short_title: "Hendrik a011f9d4-0119-4611-88af-9838ff154cec", title: "Hendrik a011f9d4-0119-4611-88af-9838ff154cec", abstract: "We've discovered the rain in Spain tends to stay in the plain", user_id: 6, paper_type: "Research", journal_id: 1, decision_letter: nil, published_at: nil, striking_image_id: nil, editable: true, doi: "yetipub/yetijour.1000001", editor_mode: "html", publishing_state: "unsubmitted", submitted_at: nil, salesforce_manuscript_id: nil, withdrawals: [], active: true},
  {short_title: "Hendrik 12de86c5-5afc-44cb-ab06-00a3411f66d5", title: "Hendrik 12de86c5-5afc-44cb-ab06-00a3411f66d5", abstract: "We've discovered the rain in Spain tends to stay in the plain", user_id: 6, paper_type: "Research", journal_id: 1, decision_letter: nil, published_at: nil, striking_image_id: nil, editable: true, doi: "yetipub/yetijour.1000002", editor_mode: "html", publishing_state: "unsubmitted", submitted_at: nil, salesforce_manuscript_id: nil, withdrawals: [], active: true},
  {short_title: "The great scientific paper of 2015", title: "The most scrumtrulescent scientific paper of 2015.", abstract: "We've discovered the rain in Spain tends to stay in the plain", user_id: 1, paper_type: "Research", journal_id: 1, decision_letter: nil, published_at: nil, striking_image_id: nil, editable: true, doi: "yetipub/yetijour.1000003", editor_mode: "html", publishing_state: "unsubmitted", submitted_at: nil, salesforce_manuscript_id: nil, withdrawals: [], active: true}
])
PaperRole.create!([
  {user_id: 6, paper_id: 1, role: "collaborator"},
  {user_id: 6, paper_id: 1, role: "participant"},
  {user_id: 6, paper_id: 2, role: "collaborator"},
  {user_id: 6, paper_id: 2, role: "participant"},
  {user_id: 1, paper_id: 3, role: "collaborator"},
  {user_id: 1, paper_id: 3, role: "participant"}
])
Task.create!([
  {title: "Figures", type: "TahiStandardTasks::FigureTask", phase_id: 1, completed: false, role: "author", body: [], position: 1},
  {title: "Supporting Info", type: "TahiStandardTasks::SupportingInformationTask", phase_id: 1, completed: false, role: "author", body: [], position: 2},
  {title: "Authors", type: "TahiStandardTasks::AuthorsTask", phase_id: 1, completed: false, role: "author", body: [], position: 3},
  {title: "Upload Manuscript", type: "TahiUploadManuscript::UploadManuscriptTask", phase_id: 1, completed: false, role: "author", body: [], position: 4},
  {title: "Cover Letter", type: "TahiStandardTasks::CoverLetterTask", phase_id: 1, completed: false, role: "author", body: [], position: 5},
  {title: "Invite Editor", type: "TahiStandardTasks::PaperEditorTask", phase_id: 2, completed: false, role: "admin", body: [], position: 1},
  {title: "Assign Admin", type: "TahiStandardTasks::PaperAdminTask", phase_id: 2, completed: false, role: "admin", body: [], position: 2},
  {title: "Invite Reviewers", type: "TahiStandardTasks::PaperReviewerTask", phase_id: 3, completed: false, role: "editor", body: [], position: 1},
  {title: "Register Decision", type: "TahiStandardTasks::RegisterDecisionTask", phase_id: 5, completed: false, role: "editor", body: [], position: 1},
  {title: "Figures", type: "TahiStandardTasks::FigureTask", phase_id: 6, completed: false, role: "author", body: [], position: 1},
  {title: "Supporting Info", type: "TahiStandardTasks::SupportingInformationTask", phase_id: 6, completed: false, role: "author", body: [], position: 2},
  {title: "Authors", type: "TahiStandardTasks::AuthorsTask", phase_id: 6, completed: false, role: "author", body: [], position: 3},
  {title: "Upload Manuscript", type: "TahiUploadManuscript::UploadManuscriptTask", phase_id: 6, completed: false, role: "author", body: [], position: 4},
  {title: "Cover Letter", type: "TahiStandardTasks::CoverLetterTask", phase_id: 6, completed: false, role: "author", body: [], position: 5},
  {title: "Invite Editor", type: "TahiStandardTasks::PaperEditorTask", phase_id: 7, completed: false, role: "admin", body: [], position: 1},
  {title: "Assign Admin", type: "TahiStandardTasks::PaperAdminTask", phase_id: 7, completed: false, role: "admin", body: [], position: 2},
  {title: "Invite Reviewers", type: "TahiStandardTasks::PaperReviewerTask", phase_id: 8, completed: false, role: "editor", body: [], position: 1},
  {title: "Register Decision", type: "TahiStandardTasks::RegisterDecisionTask", phase_id: 10, completed: false, role: "editor", body: [], position: 1},
  {title: "Figures", type: "TahiStandardTasks::FigureTask", phase_id: 11, completed: false, role: "author", body: [], position: 1},
  {title: "Supporting Info", type: "TahiStandardTasks::SupportingInformationTask", phase_id: 11, completed: false, role: "author", body: [], position: 2},
  {title: "Authors", type: "TahiStandardTasks::AuthorsTask", phase_id: 11, completed: false, role: "author", body: [], position: 3},
  {title: "Upload Manuscript", type: "TahiUploadManuscript::UploadManuscriptTask", phase_id: 11, completed: false, role: "author", body: [], position: 4},
  {title: "Cover Letter", type: "TahiStandardTasks::CoverLetterTask", phase_id: 11, completed: false, role: "author", body: [], position: 5},
  {title: "Invite Editor", type: "TahiStandardTasks::PaperEditorTask", phase_id: 12, completed: false, role: "admin", body: [], position: 1},
  {title: "Assign Admin", type: "TahiStandardTasks::PaperAdminTask", phase_id: 12, completed: false, role: "admin", body: [], position: 2},
  {title: "Invite Reviewers", type: "TahiStandardTasks::PaperReviewerTask", phase_id: 13, completed: false, role: "editor", body: [], position: 1},
  {title: "Register Decision", type: "TahiStandardTasks::RegisterDecisionTask", phase_id: 15, completed: false, role: "editor", body: [], position: 1}
])
Author.create!([
  {first_name: "Jeffrey SA", last_name: "Gray", position: 1, paper_id: 1, authors_task_id: 3, middle_initial: nil, email: "sealresq+7@gmail.com", department: nil, title: nil, corresponding: false, deceased: false, affiliation: "PLOS", secondary_affiliation: nil, contributions: nil, ringgold_id: nil, secondary_ringgold_id: nil},
  {first_name: "Jeffrey SA", last_name: "Gray", position: 2, paper_id: 2, authors_task_id: 12, middle_initial: nil, email: "sealresq+7@gmail.com", department: nil, title: nil, corresponding: false, deceased: false, affiliation: "PLOS", secondary_affiliation: nil, contributions: nil, ringgold_id: nil, secondary_ringgold_id: nil},
  {first_name: "Admin", last_name: "User", position: 3, paper_id: 3, authors_task_id: 21, middle_initial: nil, email: "admin@example.com", department: nil, title: nil, corresponding: false, deceased: false, affiliation: "PLOS", secondary_affiliation: nil, contributions: nil, ringgold_id: nil, secondary_ringgold_id: nil}
])
Participation.create!([
  {task_id: 1, user_id: 6},
  {task_id: 2, user_id: 6},
  {task_id: 3, user_id: 6},
  {task_id: 4, user_id: 6},
  {task_id: 5, user_id: 6},
  {task_id: 10, user_id: 6},
  {task_id: 11, user_id: 6},
  {task_id: 12, user_id: 6},
  {task_id: 13, user_id: 6},
  {task_id: 14, user_id: 6},
  {task_id: 19, user_id: 1},
  {task_id: 20, user_id: 1},
  {task_id: 21, user_id: 1},
  {task_id: 22, user_id: 1},
  {task_id: 23, user_id: 1}
])
User.create!([
  {first_name: "Admin", last_name: "User", email: "admin@example.com", encrypted_password: "$2a$10$xY6WtaqSrAlvFkymjMcqaOR55X8k7LXIHLmjpcPDfh8n7u2Rs5yoK", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "admin", site_admin: true, avatar: nil},
  {first_name: "Editor", last_name: "User", email: "editor@example.com", encrypted_password: "$2a$10$dEBt.FNUwqv6EbzLB/3djOZtoa5qiKQIUlC2l6o5ks7sEbiCSKKJS", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "editor", site_admin: false, avatar: nil},
  {first_name: "Reviewer", last_name: "User", email: "reviewer@example.com", encrypted_password: "$2a$10$8g4eanAJs8c9klTPYOfQ3eWBtkkYSkITCfez4BDW.5Gze3VhPIqS6", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "reviewer", site_admin: false, avatar: nil},
  {first_name: "FlowManager", last_name: "User", email: "flow_manager@example.com", encrypted_password: "$2a$10$FFl4aR/LzCnqnw6jlH9k1u/6IbESDYvz9TzxOe1dlPlN3TNlJiYpW", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "flow_manager", site_admin: false, avatar: nil},
  {first_name: "Author", last_name: "User", email: "author@example.com", encrypted_password: "$2a$10$ODwwlSh.KidhjThYqDnCHO4eObHRDDJ7HAw76bjtd8/daJyuHwAem", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "author", site_admin: false, avatar: nil},
  {first_name: "Jeffrey SA", last_name: "Gray", email: "sealresq+7@gmail.com", encrypted_password: "$2a$10$Gu.yeypGamEOcqEhoSXRyujm4pA1Bd7kuYWwn6PTacpFwK0gcO9gi", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "jgray_sa", site_admin: true, avatar: nil},
  {first_name: "Jeffrey OA", last_name: "Gray", email: "sealresq+6@gmail.com", encrypted_password: "$2a$10$3fO./TV.OjkRtkYvwYwzG.dJM4ozkf/ukR51BzV1J4/TdW7kosAA2", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "jgray_oa", site_admin: false, avatar: nil},
  {first_name: "Jeffrey FM", last_name: "Gray", email: "sealresq+5@gmail.com", encrypted_password: "$2a$10$WJqjWtT4RmBKgEXzXYqI..0yfpZ7o28H7idxk9g6Zd4K3eJhm8srC", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "jgray_flowmgr", site_admin: false, avatar: nil},
  {first_name: "Jeffrey AMM", last_name: "Gray", email: "sealresq+4@gmail.com", encrypted_password: "$2a$10$m4FNcZP5kbxl7RzUp8ZuPOrmH.Aeq6TVzm/HF7z.JOrkYeDwNGyCK", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "jgray_editor", site_admin: false, avatar: nil},
  {first_name: "Jeffrey MM", last_name: "Gray", email: "sealresq+3@gmail.com", encrypted_password: "$2a$10$Si.6GYBTsnMXokM2vxeKm.9jENBQr6wvqLANlv57oYzr/iegguRCm", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "jgray_assoceditor", site_admin: false, avatar: nil},
  {first_name: "Jeffrey RV", last_name: "Gray", email: "sealresq+2@gmail.com", encrypted_password: "$2a$10$YbCrTHsSck0Q6ruBANTQd.CoBxk3PXlwBLkzmTnWKYUzSy1cZS4dO", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "jgray_reviewer", site_admin: false, avatar: nil},
  {first_name: "Jeffrey AU", last_name: "Gray", email: "sealresq+1@gmail.com", encrypted_password: "$2a$10$UUtZUGm92m6v2bd/xp40ieQeP.NfG3CcG2sociQDcyg4RIpl.3hUC", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "jgray_author", site_admin: false, avatar: nil},
  {first_name: "Oliver", last_name: "Smith", email: "oliver.smith@example.com", encrypted_password: "$2a$10$8jeepB8oA7SCQBEHl.9KG.R9/AHMfycaNMTIRoQf8xUXPK49QV2jS", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "oliver", site_admin: false, avatar: nil},
  {first_name: "Charlotte", last_name: "Jones", email: "charlotte.jones@example.com", encrypted_password: "$2a$10$QJGK9aKpFRKJc4YLsJwydOvNrf/ADJKFH5ALkpb.E9eDCDCXKsmq6", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "charlotte", site_admin: false, avatar: nil},
  {first_name: "Jack", last_name: "Taylor", email: "jack.taylor@example.com", encrypted_password: "$2a$10$4e9Nel.osyQ0Vh1yYxoHfujvPPCB7RGAW43o6rNJ3Rvcjk4FJIjw.", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "jack", site_admin: false, avatar: nil},
  {first_name: "Emily", last_name: "Brown", email: "emily.brown@example.com", encrypted_password: "$2a$10$fyp5FD7sWSuUFOpIyZgs8.EER6/QLwDygNnLVxDvvVMZI6.576nwu", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "emily", site_admin: false, avatar: nil},
  {first_name: "James", last_name: "Davies", email: "james.davies@example.com", encrypted_password: "$2a$10$PX6fueEYblt8btK4FNyV9.c63gFSGBfxOm05jDut5zUn1k3GjkfVu", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "james", site_admin: false, avatar: nil},
  {first_name: "Ruby", last_name: "Evans", email: "ruby.evans@example.com", encrypted_password: "$2a$10$cW2v4v9Ed0.FBtWHDOQeu.AodWmGVjI3TupZreQvhMyoKtO0mxi62", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "ruby", site_admin: false, avatar: nil},
  {first_name: "William", last_name: "Roberts", email: "william.roberts@example.com", encrypted_password: "$2a$10$M/vsbl4Y1jjbOyyF8C/1sed3vk6TgenXaqBTK6jwB8rnaYZsqjrsO", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "william", site_admin: false, avatar: nil},
  {first_name: "Sophie", last_name: "Johnson", email: "sophie.johnson@example.com", encrypted_password: "$2a$10$mnMYv0PIFctXWR6TIrfnjeyKDwY0eUw1.XPJw949ijWZ2OQ20QmfG", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "sophie", site_admin: false, avatar: nil},
  {first_name: "Mason", last_name: "Robinson", email: "mason.robinson@example.com", encrypted_password: "$2a$10$gdQ0JDgmPu6Bvegs6mFiAuXZQpxI0QDrqiB.5dPMXL5aNFUATbDIW", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "mason", site_admin: false, avatar: nil},
  {first_name: "Olivia", last_name: "Edwards", email: "olivia.edwards@example.com", encrypted_password: "$2a$10$k.C02MHqnic0roBYH1ko7O8Ub4D8T.8FI0hl8ESjyyoqrgROEQR8e", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "olivia", site_admin: false, avatar: nil},
  {first_name: "Richard", last_name: "Prentice", email: "richard.prentice@example.com", encrypted_password: "$2a$10$OyDG/aNOYqi7QfQa5Z91MuvjCEFP.FhVFykGt6jDmYqJ65qKUErE.", reset_password_token: nil, reset_password_sent_at: nil, remember_created_at: nil, sign_in_count: 0, current_sign_in_at: nil, last_sign_in_at: nil, current_sign_in_ip: nil, last_sign_in_ip: nil, username: "richard", site_admin: false, avatar: nil}
])
Role.create!([
  {name: "Admin", journal_id: 1, can_administer_journal: true, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: true, kind: "admin", can_view_flow_manager: true},
  {name: "Editor", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "editor", can_view_flow_manager: false},
  {name: "Flow Manager", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "flow manager", can_view_flow_manager: true},
  {name: "Author", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 0", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 1", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 2", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 3", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 4", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 5", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 6", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 7", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 8", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 9", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false},
  {name: "Role 10", journal_id: 1, can_administer_journal: false, can_view_assigned_manuscript_managers: false, can_view_all_manuscript_managers: false, kind: "custom", can_view_flow_manager: false}
])
Affiliation.create!([
  {user_id: 1, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 2, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 3, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 4, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 5, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 6, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 7, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 8, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 9, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 10, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 11, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 12, name: "PLOS", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 13, name: "Affiliation 0", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 14, name: "Affiliation 1", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 15, name: "Affiliation 2", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 16, name: "Affiliation 3", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 17, name: "Affiliation 4", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 18, name: "Affiliation 5", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 19, name: "Affiliation 6", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 20, name: "Affiliation 7", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 21, name: "Affiliation 8", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 22, name: "Affiliation 9", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil},
  {user_id: 23, name: "Affiliation 10", start_date: nil, end_date: nil, email: nil, department: nil, title: nil, country: nil, ringgold_id: nil}
])
Decision.create!([
  {paper_id: 1, revision_number: 0, letter: nil, verdict: nil, author_response: nil},
  {paper_id: 2, revision_number: 0, letter: nil, verdict: nil, author_response: nil},
  {paper_id: 3, revision_number: 0, letter: nil, verdict: nil, author_response: nil}
])
Journal.create!([
  {name: "PLOS Yeti", logo: nil, epub_cover: nil, epub_css: nil, pdf_css: nil, manuscript_css: nil, description: nil, doi_publisher_prefix: "yetipub", doi_journal_prefix: "yetijour", last_doi_issued: "1000003"}
])
JournalTaskType.create!([
  {journal_id: 1, title: "Ad-hoc", role: "user", kind: "Task"},
  {journal_id: 1, title: "Test Task", role: "user", kind: "InvitableTask"},
  {journal_id: 1, title: "Authors", role: "author", kind: "TahiStandardTasks::AuthorsTask"},
  {journal_id: 1, title: "Competing Interests", role: "author", kind: "TahiStandardTasks::CompetingInterestsTask"},
  {journal_id: 1, title: "Cover Letter", role: "author", kind: "TahiStandardTasks::CoverLetterTask"},
  {journal_id: 1, title: "Data Availability", role: "author", kind: "TahiStandardTasks::DataAvailabilityTask"},
  {journal_id: 1, title: "Ethics Statement", role: "author", kind: "TahiStandardTasks::EthicsTask"},
  {journal_id: 1, title: "Figures", role: "author", kind: "TahiStandardTasks::FigureTask"},
  {journal_id: 1, title: "Financial Disclosure", role: "author", kind: "TahiStandardTasks::FinancialDisclosureTask"},
  {journal_id: 1, title: "Assign Admin", role: "admin", kind: "TahiStandardTasks::PaperAdminTask"},
  {journal_id: 1, title: "Invite Editor", role: "admin", kind: "TahiStandardTasks::PaperEditorTask"},
  {journal_id: 1, title: "Invite Reviewers", role: "editor", kind: "TahiStandardTasks::PaperReviewerTask"},
  {journal_id: 1, title: "Production Metadata", role: "admin", kind: "TahiStandardTasks::ProductionMetadataTask"},
  {journal_id: 1, title: "Publishing Related Questions", role: "author", kind: "TahiStandardTasks::PublishingRelatedQuestionsTask"},
  {journal_id: 1, title: "Register Decision", role: "editor", kind: "TahiStandardTasks::RegisterDecisionTask"},
  {journal_id: 1, title: "Reporting Guidelines", role: "author", kind: "TahiStandardTasks::ReportingGuidelinesTask"},
  {journal_id: 1, title: "Reviewer Candidates", role: "author", kind: "TahiStandardTasks::ReviewerRecommendationsTask"},
  {journal_id: 1, title: "Reviewer Report", role: "reviewer", kind: "TahiStandardTasks::ReviewerReportTask"},
  {journal_id: 1, title: "Revise Task", role: "author", kind: "TahiStandardTasks::ReviseTask"},
  {journal_id: 1, title: "Supporting Info", role: "author", kind: "TahiStandardTasks::SupportingInformationTask"},
  {journal_id: 1, title: "New Taxon", role: "author", kind: "TahiStandardTasks::TaxonTask"},
  {journal_id: 1, title: "Upload Manuscript", role: "author", kind: "TahiUploadManuscript::UploadManuscriptTask"},
  {journal_id: 1, title: "Changes For Author", role: "author", kind: "PlosBioTechCheck::ChangesForAuthorTask"},
  {journal_id: 1, title: "Final Tech Check", role: "author", kind: "PlosBioTechCheck::FinalTechCheckTask"},
  {journal_id: 1, title: "Initial Tech Check", role: "admin", kind: "PlosBioTechCheck::InitialTechCheckTask"},
  {journal_id: 1, title: "Revision Tech Check", role: "author", kind: "PlosBioTechCheck::RevisionTechCheckTask"},
  {journal_id: 1, title: "Editor Discussion", role: "admin", kind: "PlosBioInternalReview::EditorsDiscussionTask"},
  {journal_id: 1, title: "Billing", role: "author", kind: "PlosBilling::BillingTask"},
  {journal_id: 1, title: "Assign Team", role: "admin", kind: "Tahi::AssignTeam::AssignTeamTask"}
])
ManuscriptManagerTemplate.create!([
  {paper_type: "Research", journal_id: 1}
])
NestedQuestion.create!([
  {text: "Yes - I confirm our figures comply with the guidelines.", value_type: "boolean", ident: "figure_complies", parent_id: nil, lft: 1, rgt: 2, position: 1, owner_type: "TahiStandardTasks::FigureTask", owner_id: nil},
  {text: "This person will be listed as the corresponding author on the published article", value_type: "boolean", ident: "published_as_corresponding_author", parent_id: nil, lft: 3, rgt: 4, position: 1, owner_type: "Author", owner_id: nil},
  {text: "This person is deceased", value_type: "boolean", ident: "deceased", parent_id: nil, lft: 5, rgt: 6, position: 2, owner_type: "Author", owner_id: nil},
  {text: "Conceived and designed the experiments", value_type: "boolean", ident: "conceived_and_designed_experiments", parent_id: 4, lft: 8, rgt: 9, position: 1, owner_type: "Author", owner_id: nil},
  {text: "Performed the experiments", value_type: "boolean", ident: "performed_the_experiments", parent_id: 4, lft: 10, rgt: 11, position: 2, owner_type: "Author", owner_id: nil},
  {text: "Analyzed the data", value_type: "boolean", ident: "analyzed_data", parent_id: 4, lft: 12, rgt: 13, position: 3, owner_type: "Author", owner_id: nil},
  {text: "Contributed reagents/materials/analysis tools", value_type: "boolean", ident: "contributed_tools", parent_id: 4, lft: 14, rgt: 15, position: 4, owner_type: "Author", owner_id: nil},
  {text: "Contributed to the writing of the manuscript", value_type: "boolean", ident: "contributed_writing", parent_id: 4, lft: 16, rgt: 17, position: 5, owner_type: "Author", owner_id: nil},
  {text: "Author Contributions", value_type: "question-set", ident: "contributions", parent_id: nil, lft: 7, rgt: 20, position: 3, owner_type: "Author", owner_id: nil},
  {text: "Other", value_type: "text", ident: "other", parent_id: 4, lft: 18, rgt: 19, position: 6, owner_type: "Author", owner_id: nil}
])
Phase.create!([
  {name: "Submission Data", position: 1, paper_id: 1},
  {name: "Invite Editor", position: 2, paper_id: 1},
  {name: "Invite Reviewers", position: 3, paper_id: 1},
  {name: "Get Reviews", position: 4, paper_id: 1},
  {name: "Make Decision", position: 5, paper_id: 1},
  {name: "Submission Data", position: 1, paper_id: 2},
  {name: "Invite Editor", position: 2, paper_id: 2},
  {name: "Invite Reviewers", position: 3, paper_id: 2},
  {name: "Get Reviews", position: 4, paper_id: 2},
  {name: "Make Decision", position: 5, paper_id: 2},
  {name: "Submission Data", position: 1, paper_id: 3},
  {name: "Invite Editor", position: 2, paper_id: 3},
  {name: "Invite Reviewers", position: 3, paper_id: 3},
  {name: "Get Reviews", position: 4, paper_id: 3},
  {name: "Make Decision", position: 5, paper_id: 3}
])
PhaseTemplate.create!([
  {name: "Submission Data", manuscript_manager_template_id: 1, position: 1},
  {name: "Invite Editor", manuscript_manager_template_id: 1, position: 2},
  {name: "Invite Reviewers", manuscript_manager_template_id: 1, position: 3},
  {name: "Get Reviews", manuscript_manager_template_id: 1, position: 4},
  {name: "Make Decision", manuscript_manager_template_id: 1, position: 5}
])
TaskTemplate.create!([
  {journal_task_type_id: 8, phase_template_id: 1, template: [], title: "Figures", position: 1},
  {journal_task_type_id: 20, phase_template_id: 1, template: [], title: "Supporting Info", position: 2},
  {journal_task_type_id: 3, phase_template_id: 1, template: [], title: "Authors", position: 3},
  {journal_task_type_id: 22, phase_template_id: 1, template: [], title: "Upload Manuscript", position: 4},
  {journal_task_type_id: 5, phase_template_id: 1, template: [], title: "Cover Letter", position: 5},
  {journal_task_type_id: 11, phase_template_id: 2, template: [], title: "Invite Editor", position: 1},
  {journal_task_type_id: 10, phase_template_id: 2, template: [], title: "Assign Admin", position: 2},
  {journal_task_type_id: 12, phase_template_id: 3, template: [], title: "Invite Reviewers", position: 1},
  {journal_task_type_id: 15, phase_template_id: 5, template: [], title: "Register Decision", position: 1}
])
UserRole.create!([
  {user_id: 1, role_id: 1},
  {user_id: 2, role_id: 2},
  {user_id: 4, role_id: 3},
  {user_id: 5, role_id: 4},
  {user_id: 6, role_id: 1},
  {user_id: 7, role_id: 1},
  {user_id: 8, role_id: 3},
  {user_id: 9, role_id: 2},
  {user_id: 10, role_id: 2},
  {user_id: 12, role_id: 4},
  {user_id: 13, role_id: 5},
  {user_id: 14, role_id: 6},
  {user_id: 15, role_id: 7},
  {user_id: 16, role_id: 8},
  {user_id: 17, role_id: 9},
  {user_id: 18, role_id: 10},
  {user_id: 19, role_id: 11},
  {user_id: 20, role_id: 12},
  {user_id: 21, role_id: 13},
  {user_id: 22, role_id: 14},
  {user_id: 23, role_id: 15}
])
VersionedText.create!([
  {submitting_user_id: nil, paper_id: 1, major_version: 0, minor_version: 0, text: "<p>The quick man bear pig jumped over the fox</p>"},
  {submitting_user_id: nil, paper_id: 2, major_version: 0, minor_version: 0, text: "<p>The quick man bear pig jumped over the fox</p>"},
  {submitting_user_id: nil, paper_id: 3, major_version: 0, minor_version: 0, text: "<p>The quick man bear pig jumped over the fox</p>"}
])
