---EX. 1
SELECT course_id, credits
FROM course
WHERE credits > 3;

SELECT room_number, building
FROM classroom
WHERE building = 'Watson' or building = 'Packard';

SELECT course_id, dept_name
FROM course
WHERE dept_name = 'Comp. Sci.';

SELECT course_id, semester
FROM section
WHERE semester = 'Fall';

SELECT id, name, tot_cred
FROM student
WHERE tot_cred > 45 and tot_cred < 90;

SELECT id, name
FROM student
WHERE RIGHT(name, 1) in ('a', 'i', 'u', 'e', 'o'); ---SIMILAR TO '_%a\i\u\e\o'

SELECT course_id, prereq_id
FROM prereq
WHERE prereq_id = 'CS-101';

---EX. 2
SELECT dept_name, avg(salary)
FROM instructor
GROUP BY dept_name
ORDER BY avg(salary);

SELECT building, COUNT(course_id) as courses
FROM section
GROUP BY building
HAVING COUNT(course_id) = (SELECT MAX(c)
                           FROM (SELECT COUNT(course_id) AS c
                                 FROM section
                                 GROUP BY building) AS q);

SELECT dept_name, COUNT(course_id) as courses
FROM course
GROUP BY dept_name
HAVING COUNT(course_id) = (SELECT MIN(c)
                           FROM (SELECT COUNT(course_id) AS c
                                 FROM course
                                 GROUP BY dept_name) AS q);

SELECT student.id, name, COUNT(course_id) as courses
FROM student, takes
WHERE student.id = takes.id and dept_name = 'Comp. Sci.'
GROUP BY student.id
HAVING COUNT(course_id) > 3;

SELECT name, dept_name
FROM instructor
WHERE dept_name = 'Biology' or dept_name = 'Philosophy' or dept_name = 'Music';

SELECT name, teaches.id
FROM instructor, teaches
GROUP BY name, teaches.id, instructor.id
HAVING instructor.id = teaches.id and MIN(year) = MAX(year) and MAX(year) = 2018;

---EX. 3
SELECT DISTINCT name
FROM student, takes
WHERE student.id = takes.id and (grade = 'A' or grade = 'A-')
ORDER BY name;

SELECT DISTINCT name
FROM advisor, instructor, takes
WHERE takes.id = advisor.s_id and instructor.id = advisor.i_id and (grade > 'B' and grade != 'B+');

SELECT DISTINCT dept_name
FROM course
WHERE dept_name NOT IN (SELECT dept_name
                        FROM course, takes
                        WHERE takes.course_id = course.course_id and (grade = 'C' or grade = 'F'));

SELECT name
FROM takes, teaches, instructor
WHERE takes.course_id = teaches.course_id and teaches.id = instructor.id and takes.year = teaches.year
GROUP BY name
HAVING MIN(grade) != 'A';

---???
SELECT time_slot_id
FROM time_slot
WHERE start_hr < 13;
---???