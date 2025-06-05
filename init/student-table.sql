-- This file runs automatically when the database is first created
-- It's executed only once when the container starts for the first time

-- Create students table
CREATE TABLE IF NOT EXISTS students (
    id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE,  
    age INTEGER,
    enrollment_date DATE DEFAULT CURRENT_DATE
);

-- Create courses table
CREATE TABLE IF NOT EXISTS courses (
    id SERIAL PRIMARY KEY,
    course_name VARCHAR(100) NOT NULL,
    credits INTEGER DEFAULT 3,
    department VARCHAR(50)
);

-- Insert sample students
INSERT INTO students (name, email, age) VALUES 
('Alice Johnson', 'alice@university.edu', 22),
('Bob Smith', 'bob@university.edu', 24),
('Carol Davis', 'carol@university.edu', 23),
('David Wilson', 'david@university.edu', 21),
('Emma Brown', 'emma@university.edu', 25)
ON CONFLICT (email) DO NOTHING;

-- Insert sample courses
INSERT INTO courses (course_name, credits, department) VALUES 
('Introduction to Computer Science', 4, 'CS'),
('Database Systems', 3, 'CS'),
('Calculus I', 4, 'Math'),
('English Literature', 3, 'English'),
('Physics I', 4, 'Physics')
ON CONFLICT DO NOTHING;

-- Create enrollments table (many-to-many relationship)
CREATE TABLE IF NOT EXISTS enrollments (
    student_id INTEGER REFERENCES students(id),
    course_id INTEGER REFERENCES courses(id),
    grade VARCHAR(2),
    enrollment_semester VARCHAR(20),
    PRIMARY KEY (student_id, course_id)
);

-- Insert sample enrollments
INSERT INTO enrollments (student_id, course_id, grade, enrollment_semester) VALUES 
(1, 1, 'A', 'Fall 2024'),
(1, 2, 'B+', 'Fall 2024'),
(2, 1, 'B', 'Fall 2024'),
(2, 3, 'A-', 'Fall 2024'),
(3, 2, 'A', 'Fall 2024'),
(3, 4, 'B+', 'Fall 2024')
ON CONFLICT DO NOTHING;