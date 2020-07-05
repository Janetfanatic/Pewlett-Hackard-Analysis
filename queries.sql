-- Data collected during work with module 7, some utilized during challenge below.
-- 1. Create new table for employees eligible for retirement
SELECT emp_no, first_name, last_name
INTO retirement_info
FROM employees
WHERE (birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (hire_date BETWEEN '1985-01-01' AND '1988-12-31');
-- Check the table
SELECT * FROM retirement_info;
​
-- 2. People who are eligible for retirement, but still working at the company
SELECT ri.emp_no,
	ri.first_name,
	ri.last_name,
de.to_date
INTO current_emp
FROM retirement_info as ri
LEFT JOIN dept_employee as de
ON ri.emp_no = de.emp_no
WHERE de.to_date = ('9999-01-01');
-- Check the table
SELECT * FROM current_emp;
​
​
-- 3. How many people eligible for retirement by department
SELECT * FROM current_emp;
-- Employee count by department number
SELECT COUNT(ce.emp_no), de.dept_no
INTO retirement_by_dept
FROM current_emp as ce
LEFT JOIN dept_employee as de
ON ce.emp_no = de.emp_no
GROUP BY de.dept_no
ORDER BY de.dept_no;
SELECT * FROM salaries
ORDER BY to_date DESC;
-- Check the table
SELECT * FROM retirement_by_dept;
​
-- 4. Create comprehensive list of employees
SELECT e.emp_no,
	   e.first_name,
	   e.last_name,
	   e.gender,
	   s.salary,
	   de.to_date
INTO emp_info
FROM employees as e
INNER JOIN salaries as s
ON (e.emp_no = s.emp_no)
INNER JOIN dept_employee as de
ON (e.emp_no = de.emp_no)
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')
AND (e.hire_date BETWEEN '1985-01-01' AND '1988-12-31')
AND (de.to_date = '9999-01-01');
​
​
-- 5. List of managers and their departments who are eligible for retirement
-- (keep in mind for hiring purposes)
SELECT  dm.dept_no,
        d.dept_name,
        dm.emp_no,
        ce.last_name,
        ce.first_name,
        dm.from_date,
        dm.to_date
INTO manager_info
FROM dept_manager AS dm
    INNER JOIN departments AS d
        ON (dm.dept_no = d.dept_no)
    INNER JOIN current_emp AS ce
        ON (dm.emp_no = ce.emp_no);
​
-- 6. List of departments with employees who are eligible for retirement
SELECT ce.emp_no,
      ce.first_name,
      ce.last_name,
      d.dept_name	
INTO dept_info
FROM current_emp as ce
INNER JOIN dept_employee AS de
ON (ce.emp_no = de.emp_no)
INNER JOIN departments AS d
ON (de.dept_no = d.dept_no);
​
​
-- 7. Select the Sales dept employees who are eligible to retire
SELECT ce.emp_no, 
      ce.first_name, 
      ce.last_name, 
      de.dept_no
INTO sales_info
FROM current_emp as ce
INNER JOIN dept_employee as de
  ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d
  ON (de.dept_no = d.dept_no)
WHERE d.dept_name = 'Sales';
​
-- SELECT rdn.emp_no,
--       rdn.first_name,
--       rdn.last_name,
--       d.dept_name
-- INTO retirement_mentorship_group
-- FROM retirement_dept_no AS rdn
-- LEFT JOIN departments AS d
-- ON (rdn.dept_no = d.dept_no)
-- WHERE d.dept_name IN ('Sales', 'Development');
​
-- 8. Select the Sales dept employees AND Dev dept who are eligible to retire
SELECT ce.emp_no, 
      ce.first_name, 
      ce.last_name, 
      de.dept_no
INTO devel_sales_info
FROM current_emp as ce
INNER JOIN dept_employee as de
  ON (ce.emp_no = de.emp_no)
INNER JOIN departments as d
  ON (de.dept_no = d.dept_no)
WHERE d.dept_name IN ('Sales', 'Development');
​
-- WEEK 7 CHALLENGE ---------------------------------------
​
​-- Deliverable 1: Number of Retiring Employees by Title

-- Table 1 without correction for duplicate
-- number of [titles] retiring
SELECT ce.emp_no,
	   ce.first_name,
	   ce.last_name,
	   t.title,
	   s.from_date,
	   s.salary	   
INTO future_retires_with_titles
FROM current_emp AS ce
INNER JOIN titles as t
ON (ce.emp_no = t.emp_no)
INNER JOIN salaries As s
ON (s.emp_no = ce.emp_no)

-- Start of duplicate correction
-- number of [titles] retiring(duplicate correction)
SELECT ce.emp_no,
	   ce.first_name,
	   ce.last_name,
	   t.title,
	   s.from_date,
	   s.to_date,
	   s.salary	   
INTO titles_retiring
FROM current_emp AS ce
INNER JOIN titles as t
ON (ce.emp_no = t.emp_no)
INNER JOIN salaries As s
ON (s.emp_no = ce.emp_no)
-- Partition the data to remove duplication in number [title] retiring list
-- Table 1 with duplicate correction
SELECT emp_no,
	   first_name,
	   last_name,
	   title,
	   from_date,
	   salary	   
INTO modified_titles_retiring
FROM  
 (SELECT *, ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY to_date DESC) rn
 FROM titles_retiring
 ) tmp WHERE rn = 1
ORDER BY emp_no;

-- Table 2
-- number of future retiring employees per title
SELECT COUNT(mtr.emp_no), mtr.title
INTO no_ret_emp_per_title
FROM modified_titles_retiring AS mtr
GROUP BY mtr.title;
​
​-- Table 3
-- Current employees list refined by birth date
SELECT mtr.emp_no,
	   mtr.first_name, 
	   mtr.last_name
INTO new_cur_emp_list
FROM modified_titles_retiring AS mtr
INNER JOIN employees AS e
ON mtr.emp_no = e.emp_no
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')

-- Deliverable 2: Mentorship Eligibility

SELECT mtr.emp_no,
       mtr.first_name,
	   mtr.last_name,
	   t.title,
	   t.from_date,
	   t.to_date
INTO new_ment_group
FROM modified_titles_retiring AS mtr
INNER JOIN titles AS t
ON mtr.emp_no = t.emp_no
INNER JOIN employees AS e
ON mtr.emp_no = e.emp_no
WHERE (e.birth_date BETWEEN '1952-01-01' AND '1955-12-31')

-- Partition the data to remove duplication in mentorship list
SELECT emp_no,
       first_name,
	   last_name,
	   title,
	   from_date,
	   to_date	   
INTO modified_new_ment_group
FROM  
 (SELECT *, ROW_NUMBER() OVER
 (PARTITION BY (emp_no)
 ORDER BY to_date DESC) rn
 FROM new_ment_group
 ) tmp WHERE rn = 1
ORDER BY emp_no;

