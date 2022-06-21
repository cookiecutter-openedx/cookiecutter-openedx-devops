/*---------------------------------------------------------------------------
 * written by:		lawrence mcdaniel
 *					https://lawrencemcdaniel.com
 *
 * date:			june-2022
 *
 * usage:			delete a user
 *---------------------------------------------------------------------------*/
SET @username = 'mcdaniel';
use openedx;

DELETE FROM openedx.schedules_scheduleexperience
WHERE	(id IN 	(
				select id from (
								SELECT se.id
								FROM openedx.schedules_schedule s
									JOIN openedx.schedules_scheduleexperience se on (s.id = se.schedule_id)
									JOIN openedx.student_courseenrollment c ON (s.enrollment_id = c.id)
									JOIN openedx.auth_user u ON (u.id = c.user_id)
								WHERE	(u.username = @username)
                                ) as d
                )
		);

DELETE FROM openedx.schedules_schedule
WHERE	(id IN 	(
				select id from (
								SELECT s.id
								FROM openedx.schedules_schedule s
									JOIN openedx.student_courseenrollment c ON (s.enrollment_id = c.id)
									JOIN openedx.auth_user u ON (u.id = c.user_id)
								WHERE	(u.username = @username)
                                ) as d
                )
		);

DELETE FROM openedx.student_manualenrollmentaudit
WHERE	(id IN 	(
				select id from (
								SELECT s.id
								FROM openedx.student_manualenrollmentaudit s
									JOIN openedx.student_courseenrollment c ON (s.enrollment_id = c.id)
									JOIN openedx.auth_user u ON (u.id = c.user_id)
								WHERE	(u.username = @username)
                                ) as d
                )
		);


DELETE FROM openedx.user_api_usercoursetag
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.user_api_usercoursetag c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);


DELETE FROM openedx.courseware_studentmodule
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.courseware_studentmodule c JOIN openedx.auth_user u ON (u.id = c.student_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM openedx.student_manualenrollmentaudit
WHERE	(id IN 	(
				select id from (
								SELECT s.id FROM openedx.student_manualenrollmentaudit s JOIN openedx.auth_user u ON (u.id = s.enrolled_by_id) WHERE (u.username = @username)
                                ) as d
                )
		);


DELETE FROM openedx.student_courseenrollment
WHERE	(id IN 	(
				select id from (
								SELECT s.id FROM openedx.student_courseenrollment s JOIN openedx.auth_user u ON (u.id = s.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);



DELETE FROM	openedx.auth_registration
WHERE	(id IN 	(
				select id from (
								SELECT r.id FROM openedx.auth_registration r JOIN openedx.auth_user u ON (u.id = r.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.auth_userprofile
WHERE	(id IN 	(
				select id from (
								SELECT p.id FROM openedx.auth_userprofile p JOIN openedx.auth_user u ON (u.id = p.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.completion_blockcompletion
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.completion_blockcompletion c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.course_groups_cohortmembership
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.course_groups_cohortmembership c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.course_groups_courseusergroup_users
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.course_groups_courseusergroup_users c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.django_comment_client_role_users
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.django_comment_client_role_users c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.experiments_experimentdata
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.experiments_experimentdata c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.oauth2_provider_refreshtoken
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.oauth2_provider_refreshtoken c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);


DELETE FROM	openedx.oauth2_provider_accesstoken
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.oauth2_provider_accesstoken c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.schedules_historicalschedule
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.schedules_historicalschedule c JOIN openedx.auth_user u ON (u.id = c.history_user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.social_auth_usersocialauth
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.social_auth_usersocialauth c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.student_anonymoususerid
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.student_anonymoususerid c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.student_courseenrollment_history
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.student_courseenrollment_history c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.student_courseenrollment_history
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.student_courseenrollment_history c JOIN openedx.auth_user u ON (u.id = c.history_user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.student_userattribute
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.student_userattribute c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.user_api_userpreference
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.user_api_userpreference c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.verify_student_ssoverification
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.verify_student_ssoverification c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.course_creators_coursecreator
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.course_creators_coursecreator c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.course_overviews_historicalcourseoverview
WHERE	(history_user_id IN 	(
				select history_user_id from (
								SELECT c.history_user_id FROM openedx.course_overviews_historicalcourseoverview c JOIN openedx.auth_user u ON (u.id = c.history_user_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.gcsi_cms_coursechangelog
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.gcsi_cms_coursechangelog c JOIN openedx.auth_user u ON (u.id = c.published_by_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.gcsi_cms_coursechangelog
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.gcsi_cms_coursechangelog c JOIN openedx.auth_user u ON (u.id = c.edited_by_id) WHERE (u.username = @username)
                                ) as d
                )
		);

DELETE FROM	openedx.student_courseaccessrole
WHERE	(id IN 	(
				select id from (
								SELECT c.id FROM openedx.student_courseaccessrole c JOIN openedx.auth_user u ON (u.id = c.user_id) WHERE (u.username = @username)
                                ) as d
                )
		);


DELETE FROM	openedx.auth_user WHERE (username = @username);
