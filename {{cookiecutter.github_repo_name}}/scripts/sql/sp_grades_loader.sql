USE openedx;

DELIMITER $$
CREATE PROCEDURE sp_grades_loader()
   BEGIN
   # --------------------------------------------------------------------------------------
   # written by: 	Lawrence McDaniel
   #				   https://lawrencemcdaniel.com
   #
   # date:			May-2022
   #
   # usage:			Data migration Koa to Maple
   #				   migrate grade data in transaction batches of 500k records each
   # --------------------------------------------------------------------------------------
    DECLARE a INT Default 0 ;
	  SELECT 'sp_grades_loader() - begin';
	  SET autocommit=0;
      grade_loader_loop: LOOP
         SET a=a+1;
         IF a=4 THEN
            LEAVE grade_loader_loop;
         END IF;
         START TRANSACTION;
			INSERT INTO openedx.courseware_studentmodule
				SELECT	i.id, i.module_type, i.module_id, i.course_id, i.state, i.grade, i.max_grade, i.done, i.created, i.modified, maple_user.id as student_id
				FROM	edxapp.courseware_studentmodule i
						JOIN edxapp.auth_user koa_user ON (i.student_id = koa_user.id)
						JOIN openedx.auth_user maple_user ON (koa_user.username = maple_user.username)
						LEFT JOIN openedx.courseware_studentmodule d ON (i.id = d.id)
				WHERE	(d.id IS NULL)
				LIMIT 500000;

			SELECT a;
        COMMIT;
   END LOOP grade_loader_loop;
   SET autocommit=1;
  SELECT 'sp_grades_loader() - end';
END $$
DELIMITER ;
