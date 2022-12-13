/*---------------------------------------------------------------------------
 * written by:		lawrence mcdaniel
 *					https://lawrencemcdaniel.com
 *
 * date:			june-2022
 *
 * usage:			delete a user
 *---------------------------------------------------------------------------*/
SET @username = 'mcdaniel';
SET @db = 'edxapp';
use @db;

DELETE FROM @db.schedules_scheduleexperience
WHERE	(id IN 	(
				select id from (
								SELECT se.id
								FROM @db.schedules_schedule s
									JOIN @db.schedules_scheduleexperience se on (s.id = se.schedule_id)
									JOIN @db.student_courseenrollment c ON (s.enrollment_id = c.id)
									JOIN @db.auth_user u ON (u.id = c.user_id)
								WHERE	(u.username = @username)
                                ) as d
                )
		);

DELETE FROM @db.schedules_schedule
WHERE	(id IN 	(
				select id from (
								SELECT s.id
								FROM @db.schedules_schedule s
									JOIN @db.student_courseenrollment c ON (s.enrollment_id = c.id)
									JOIN @db.auth_user u ON (u.id = c.user_id)
								WHERE	(u.username = @username)
                                ) as d
                )
		);

DELETE FROM @db.student_manualenrollmentaudit
WHERE	(id IN 	(
				select id from (
								SELECT s.id
								FROM @db.student_manualenrollmentaudit s
									JOIN @db.student_courseenrollment c ON (s.enrollment_id = c.id)
									JOIN @db.auth_user u ON (u.id = c.user_id)
								WHERE	(u.username = @username)
                                ) as d
                )
		);


DELETE FROM @db.user_api_usercoursetag
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.user_api_usercoursetag c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);


DELETE FROM @db.courseware_studentmodule
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.courseware_studentmodule c JOIN @db.auth_user u ON (u.id = c.student_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM @db.student_manualenrollmentaudit
WHERE	(id IN 	(
				select id from (
								SELECT s.id FROM @db.student_manualenrollmentaudit s JOIN @db.auth_user u ON (u.id = s.enrolled_by_id) WHERE (u.username = @username)
                                ) as d
                )
		);


DELETE FROM @db.student_courseenrollment
WHERE	(id IN 	(
				select id from (
								SELECT s.id FROM @db.student_courseenrollment s JOIN @db.auth_user u ON (u.id = s.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);



DELETE FROM	@db.auth_registration
WHERE	(id IN 	(
				select id from (
								SELECT r.id FROM @db.auth_registration r JOIN @db.auth_user u ON (u.id = r.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.auth_userprofile
WHERE	(id IN 	(
				select id from (
								SELECT p.id FROM @db.auth_userprofile p JOIN @db.auth_user u ON (u.id = p.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.completion_blockcompletion
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.completion_blockcompletion c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.course_groups_cohortmembership
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.course_groups_cohortmembership c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.course_groups_courseusergroup_users
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.course_groups_courseusergroup_users c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.django_comment_client_role_users
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.django_comment_client_role_users c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.experiments_experimentdata
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.experiments_experimentdata c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.oauth2_provider_refreshtoken
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.oauth2_provider_refreshtoken c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);


DELETE FROM	@db.oauth2_provider_accesstoken
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.oauth2_provider_accesstoken c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.schedules_historicalschedule
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.schedules_historicalschedule c JOIN @db.auth_user u ON (u.id = c.history_user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.social_auth_usersocialauth
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.social_auth_usersocialauth c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.student_anonymoususerid
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.student_anonymoususerid c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.student_courseenrollment_history
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.student_courseenrollment_history c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.student_courseenrollment_history
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.student_courseenrollment_history c JOIN @db.auth_user u ON (u.id = c.history_user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.student_userattribute
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.student_userattribute c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.user_api_userpreference
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.user_api_userpreference c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.verify_student_ssoverification
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.verify_student_ssoverification c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.course_creators_coursecreator
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.course_creators_coursecreator c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.course_overviews_historicalcourseoverview
WHERE	(history_user_id IN 	(
				select history_user_id from (
								SELECT c.history_user_id FROM @db.course_overviews_historicalcourseoverview c JOIN @db.auth_user u ON (u.id = c.history_user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.gcsi_cms_coursechangelog
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.gcsi_cms_coursechangelog c JOIN @db.auth_user u ON (u.id = c.published_by_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.gcsi_cms_coursechangelog
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.gcsi_cms_coursechangelog c JOIN @db.auth_user u ON (u.id = c.edited_by_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	@db.student_courseaccessrole
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.student_courseaccessrole c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);


DELETE FROM @db.auth_accountrecovery
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.auth_accountrecovery c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM @db.student_loginfailures
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.student_loginfailures c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM @db.user_tours_usertour
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM @db.student_loginfailures c JOIN @db.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);


DELETE FROM	@db.auth_user WHERE (username = @username);
