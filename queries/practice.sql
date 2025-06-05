-- Practice SQL Queries


-- Basic SELECT queries
-- =====================

-- 1. View all students
SELECT * FROM students;

-- 2. View students older than 22
SELECT name, age FROM students WHERE age > 22;

-- 3. View students by age (oldest first)
SELECT name, age FROM students ORDER BY age DESC;

-- JOIN queries
-- ============

-- 4. Show student names with their enrolled courses
SELECT s.name AS student_name, c.course_name, e.grade
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id;

-- 5. Show courses with student count
SELECT c.course_name, COUNT(e.student_id) as student_count
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.course_name
ORDER BY student_count DESC;

-- Advanced queries
-- ================

-- 6. Students not enrolled in any course
SELECT s.name
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
WHERE e.student_id IS NULL;

-- 7. Average age of students by department (via their courses)
SELECT c.department, AVG(s.age) as avg_age
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id
GROUP BY c.department;

-- Data modification practice
-- ==========================

-- 8. Add a new student
INSERT INTO students (name, email, age) 
VALUES ('Your Name', 'your.email@university.edu', 23);

-- 9. Update a student's age
UPDATE students 
SET age = 26 
WHERE name = 'Alice Johnson';

-- 10. Add a new course
INSERT INTO courses (course_name, credits, department) 
VALUES ('Advanced Database Design', 3, 'CS');

-- Window functions (PostgreSQL specific)
-- ======================================

-- 11. Rank students by age
SELECT name, age, 
       RANK() OVER (ORDER BY age DESC) as age_rank
FROM students;

-- 12. Show each student with total credits enrolled
SELECT s.name,
       SUM(c.credits) OVER (PARTITION BY s.id) as total_credits
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id;

-- Useful utility queries
-- ======================

-- 13. Show table structure
-- Run these individually in psql or pgAdmin
-- \d students
-- \d courses
-- \d enrollments

-- 14. Show all tables
-- \dt

-- 15. Current database info
SELECT current_database(), current_user, now();