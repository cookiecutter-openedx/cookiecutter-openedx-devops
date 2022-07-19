/*--------------------------------------------------------------------------------------
 * written by:	Lawrence McDaniel
 *				      https://lawrencemcdaniel.com
 *
 * date:		May-2022
 *
 * usage:
 * ------
 * Migration of MySQL data from Koa to Maple. The SQL in this module assumes that
 * 1. you are beginning with a freshly installed instance of Maple, created by Tutor.
 * 2. you have restored a complete MySQL backup of your Koa data onto your new Maple
 *    MySQL server instance such that the Koa edxapp db and the Maple openedx databases
 *    sit side by side on the same MySQL server instance.
 *
 * BE AWARE THAT THIS SQL DOES NOT MIGRATE EVERY TABLE IN THE KOA MYSQL DATABASES.
 * MIGRATION OPERATIONS ARE LIMITED TO THE FOLLOWING:
 * - course_overview data
 * - auth_user
 * - auth_userprofile
 * - student session state and account lifecycle data
 * - bookmark data
 * - student_courseenrollment data
 * - courseware_studentmodule (Grade data)
 * - certificates data
 *
 * notes:
 * ------
 * - You can safely execute these queries multiple times.
 * - Where possible the SQL uses identity inserts.
 * - The most important thing this SQL does is to correctly map the auth_user.id
 *   from the Koa to the Maple database.
 * - The 2nd most important thing it does is to,
 *   where necessary, map the table fields from Koa to Maple.
 *--------------------------------------------------------------------------------------*/
SELECT count(*) FROM edxapp.badges_coursecompleteimageconfiguration;
SELECT count(*) FROM edxapp.verify_student_manualverification;

/* ---------------------------------------------------------------------------------------
# Note: ignores the following fields that are new in Maple, relative to what's in Koa:
# 	has_any_active_web_certificates
# 	catalogue_visibility
# 	certficate_availability_date
# 	has_highlights
# 	allow_proctoring_opt_out
# 	enable_proctored_exams
# 	proctoring_escalation_email, i.proctoring_provider
# ---------------------------------------------------------------------------------------*/
INSERT INTO openedx.course_overviews_courseoverview (created, modified, version, id, _location, display_name, display_number_with_default, display_org_with_default, start, end, advertised_start, course_image_url, social_sharing_url, end_of_course_survey_url, certificates_display_behavior, certificates_show_before_end, cert_html_view_enabled, cert_name_short, cert_name_long, lowest_passing_grade, days_early_for_beta, mobile_available, visible_to_staff_only, _pre_requisite_courses_json, enrollment_start, enrollment_end, enrollment_domain, invitation_only, max_student_enrollments_allowed, announcement, course_video_url, effort, short_description, org, self_paced, marketing_url, eligible_for_financial_aid, language, end_date, start_date, banner_image_url)
	SELECT	i.created, i.modified, i.version, i.id, i._location, i.display_name, i.display_number_with_default, i.display_org_with_default, i.start, i.end, i.advertised_start, i.course_image_url, i.social_sharing_url, i.end_of_course_survey_url, i.certificates_display_behavior, i.certificates_show_before_end, i.cert_html_view_enabled, i.cert_name_short, i.cert_name_long, i.lowest_passing_grade, i.days_early_for_beta, i.mobile_available, i.visible_to_staff_only, i._pre_requisite_courses_json, i.enrollment_start, i.enrollment_end, i.enrollment_domain, i.invitation_only, i.max_student_enrollments_allowed, i.announcement, i.course_video_url, i.effort, i.short_description, i.org, i.self_paced, i.marketing_url, i.eligible_for_financial_aid, i.language, i.end_date, i.start_date, i.course_image_url as banner_image_url
	FROM	edxapp.course_overviews_courseoverview i
			LEFT JOIN openedx.course_overviews_courseoverview d ON (i.id = d.id)
	WHERE	(d.id IS NULL);

INSERT INTO openedx.course_overviews_courseoverviewtab
	SELECT	i.*
	FROM	edxapp.course_overviews_courseoverviewtab i
			LEFT JOIN openedx.course_overviews_courseoverviewtab d ON (i.id = d.id)
	WHERE	(d.id IS NULL);

INSERT INTO openedx.course_overviews_historicalcourseoverview (created, modified, version, id, _location, org, display_name, display_number_with_default, display_org_with_default, start, end , advertised_start, announcement, course_image_url, social_sharing_url, end_of_course_survey_url, certificates_display_behavior, certificates_show_before_end, cert_html_view_enabled, has_any_active_web_certificate, cert_name_short, cert_name_long, certificate_available_date, lowest_passing_grade, days_early_for_beta, mobile_available, visible_to_staff_only, _pre_requisite_courses_json, enrollment_start, enrollment_end, enrollment_domain, invitation_only, max_student_enrollments_allowed, catalog_visibility, short_description)
	SELECT	i.created, i.modified, i.version, i.id, i._location, i.org, i.display_name, i.display_number_with_default, i.display_org_with_default, i.start, i.end , i.advertised_start, i.announcement, i.course_image_url, i.social_sharing_url, i.end_of_course_survey_url, i.certificates_display_behavior, i.certificates_show_before_end, i.cert_html_view_enabled, i.has_any_active_web_certificate, i.cert_name_short, i.cert_name_long, i.certificate_available_date, i.lowest_passing_grade, i.days_early_for_beta, i.mobile_available, i.visible_to_staff_only, i._pre_requisite_courses_json, i.enrollment_start, i.enrollment_end, i.enrollment_domain, i.invitation_only, i.max_student_enrollments_allowed, i.catalog_visibility, i.short_description
	FROM	edxapp.course_overviews_historicalcourseoverview i
			LEFT JOIN openedx.course_overviews_historicalcourseoverview d ON (i.history_id = d.history_id)
	WHERE	(d.history_id IS NULL);

INSERT INTO openedx.auth_user
	SELECT 	koa.*
	FROM 	edxapp.auth_user koa
			LEFT JOIN openedx.auth_user maple ON (koa.username = maple.username)
	WHERE	(koa.id > 4) AND		-- the user records automatically created by Tutor
			(maple.id IS NULL);

INSERT INTO openedx.auth_userprofile (id, name, meta, courseware, language, location, year_of_birth, gender, level_of_education, mailing_address, city, country, goals, bio, profile_image_uploaded_at, user_id, phone_number, state)
	SELECT koa.id, koa.name, koa.meta, koa.courseware, koa.language, koa.location, koa.year_of_birth, koa.gender, koa.level_of_education, koa.mailing_address, koa.city, koa.country, koa.goals, koa.bio, koa.profile_image_uploaded_at, maple_user.id, koa.phone_number, koa.state
    FROM edxapp.auth_userprofile koa
		 JOIN edxapp.auth_user koa_user ON (koa.user_id = koa_user.id)
		 JOIN openedx.auth_user maple_user ON (koa_user.username = maple_user.username)
		 LEFT JOIN openedx.auth_userprofile maple ON (maple_user.id = maple.user_id)
	WHERE (maple.id IS NULL);

INSERT INTO openedx.student_loginfailures
	SELECT 	i.*
	FROM	edxapp.student_loginfailures i
			JOIN edxapp.auth_user koa_user ON (i.user_id = koa_user.id)
			JOIN openedx.auth_user maple_user ON (koa_user.username = maple_user.username)
			LEFT JOIN openedx.student_loginfailures d ON (maple_user.id = d.user_id)
	WHERE	(d.id IS NULL);

INSERT openedx.student_pendingemailchange
	SELECT	i.*
	FROM	edxapp.student_pendingemailchange i
			JOIN edxapp.auth_user koa_user ON (i.user_id = koa_user.id)
			JOIN openedx.auth_user maple_user ON (koa_user.username = maple_user.username)
            LEFT JOIN openedx.student_pendingemailchange d ON (maple_user.id = d.user_id)
	WHERE	(d.id IS NULL);

INSERT openedx.bookmarks_xblockcache
	SELECT 	i.*
	FROM	edxapp.bookmarks_xblockcache i
			LEFT JOIN openedx.bookmarks_xblockcache d ON (i.course_key = d.course_key) AND (i.usage_key = d.usage_key)
	WHERE	(d.id IS NULL);

INSERT INTO openedx.bookmarks_bookmark (created, modified, course_key, usage_key, path, user_id, xblock_cache_id)
	SELECT	i.created, i.modified, i.course_key, i.usage_key, i.path, maple_user.id as user_id, i.xblock_cache_id
    FROM	edxapp.bookmarks_bookmark i
			JOIN edxapp.auth_user koa_user ON (i.user_id = koa_user.id)
			JOIN openedx.auth_user maple_user ON (koa_user.username = maple_user.username)
            LEFT JOIN openedx.bookmarks_bookmark dest ON ((i.course_key = dest.course_key) AND
														  (i.usage_key = dest.usage_key) AND
														  (dest.user_id = maple_user.id))
	WHERE 	(dest.id IS NULL);

INSERT INTO openedx.student_courseenrollment (course_id, created, is_active, mode, user_id)
	SELECT	i.course_id, i.created, i.is_active, i.mode, maple_user.id as user_id
	FROM 	edxapp.student_courseenrollment i
			JOIN edxapp.auth_user koa_user ON (i.user_id = koa_user.id)
			JOIN openedx.auth_user maple_user ON (koa_user.username = maple_user.username)
            LEFT JOIN openedx.student_courseenrollment d ON (d.user_id = maple_user.id)
	WHERE	(d.id IS NULL);

INSERT INTO openedx.student_courseenrollment_history
	SELECT	i.id, i.created, i.is_active, i.mode, i.history_id, i.history_date, i.history_change_reason, i.history_type, i.course_id, maple_history_user.id as history_user_id, maple_user.id as user_id
	FROM	edxapp.student_courseenrollment_history i
			JOIN edxapp.auth_user koa_user ON (i.user_id = koa_user.id)
			JOIN openedx.auth_user maple_user ON (koa_user.username = maple_user.username)
            LEFT JOIN edxapp.auth_user koa_history_user ON (i.history_user_id = koa_history_user.id)
            LEFT JOIN openedx.auth_user maple_history_user ON (koa_user.username = maple_history_user.username)
            LEFT JOIN openedx.student_courseenrollment_history d ON (i.id = d.id)
	WHERE	(d.id IS NULL);

INSERT INTO openedx.student_historicalmanualenrollmentaudit
	SELECT	i.*
	FROM	edxapp.student_historicalmanualenrollmentaudit i
			LEFT JOIN openedx.student_historicalmanualenrollmentaudit d ON (i.id = d.id)
	WHERE	(d.id IS NULL);

INSERT INTO openedx.student_manualenrollmentaudit
	SELECT	i.*
	FROM	edxapp.student_manualenrollmentaudit i
			LEFT JOIN openedx.student_manualenrollmentaudit d ON (i.id = d.id)
	WHERE	(d.id IS NULL);

INSERT INTO openedx.certificates_generatedcertificate
	SELECT	i.id, i.course_id, i.verify_uuid, i.download_uuid, i.download_url, i.grade, i.key, i.distinction, i.status, i.mode, i.name, i.created_date, i.modified_date, i.error_reason, maple_user.id as user_id
	FROM	edxapp.certificates_generatedcertificate i
			JOIN edxapp.auth_user koa_user ON (i.user_id = koa_user.id)
			JOIN openedx.auth_user maple_user ON (koa_user.username = maple_user.username)
            LEFT JOIN openedx.certificates_generatedcertificate d ON (i.id = d.id)
	WHERE	(d.id IS NULL);

INSERT INTO openedx.certificates_historicalgeneratedcertificate (id, course_id, verify_uuid, download_uuid, download_url, grade, `key`, distinction, status, mode, name, created_date, modified_date, error_reason, history_id, history_date, history_type, history_user_id, user_id)
	SELECT	i.id, i.course_id, i.verify_uuid, i.download_uuid, i.download_url, i.grade, i.key, i.distinction, i.status, i.mode, i.name, i.created_date, i.modified_date, i.error_reason, i.history_id, i.history_date, i.history_type, maple_history_user.id as history_user_id, maple_user.id as user_id
	FROM	edxapp.certificates_historicalgeneratedcertificate i
			JOIN edxapp.auth_user koa_user ON (i.user_id = koa_user.id)
			JOIN openedx.auth_user maple_user ON (koa_user.username = maple_user.username)
            LEFT JOIN edxapp.auth_user koa_history_user ON (i.history_user_id = koa_history_user.id)
            LEFT JOIN openedx.auth_user maple_history_user ON (koa_user.username = maple_history_user.username)
            LEFT JOIN openedx.certificates_historicalgeneratedcertificate d ON (i.id = d.id)
	WHERE	(d.id IS NULL);

/* -------------------------------------------------------------------
# NOTE: if you have more than 500,000 records in
# courseware_studentmodule then you might consider using
# the stored procedure LOAD_GRADES, located in this same folder.
# ------------------------------------------------------------------- */
INSERT INTO openedx.courseware_studentmodule
	SELECT	i.id, i.module_type, i.module_id, i.course_id, i.state, i.grade, i.max_grade, i.done, i.created, i.modified, maple_user.id as student_id
	FROM	edxapp.courseware_studentmodule i
			JOIN edxapp.auth_user koa_user ON (i.student_id = koa_user.id)
			JOIN openedx.auth_user maple_user ON (koa_user.username = maple_user.username)
			LEFT JOIN openedx.courseware_studentmodule d ON (i.id = d.id)
	WHERE	(d.id IS NULL)
	LIMIT 500000;			-- on AWS RDS you can safely execute this a couple of times.
							      -- But afterwards, you should be mindful that IO performance
                    -- depends largely on your available burst credits, which will
                    -- quickly vanish on t2.* instance families if you execute this
                    -- statement more than a couple of times.
