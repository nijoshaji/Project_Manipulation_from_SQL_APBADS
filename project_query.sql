# 1. Identify employees with the highest total hours worked and least absenteeism. 
#(include employees with no work hours as well)

select emp.employeeid, emp.employeename, 
sum(att.total_hours*att.days_present) as total_hours_worked,
avg(att.total_hours) as avg_hours_worked, 
sum(days_present) as total_days_worked,
(sum(att.total_hours)*sum(days_present)) as p_score,
sum(att.days_absent) as total_days_abs
from employee_details emp
left join attendance_records att  on att.employeeid = emp.employeeid
group by emp.employeeid, emp.employeename
order by sum(att.total_hours*att.days_present) desc, sum(att.days_absent) asc;

# 2. Analyze how training programs improve departmental performance.
## trial 1
select avg(case 
 when performance_score = 'Excellent' then 5
 when performance_score = 'Good' then 4
 when performance_score = 'Average' then 3
 when performance_score = 'Poor' then 2
 else 1 end) as  avg_score
from employee_details group by department_id;

select e.department_id, 
avg(case 
	when e.performance_score = 'Excellent' then 5
	when e.performance_score = 'Good' then 4
	when e.performance_score = 'Average' then 3
	else 0
end) as avg_dep_score,
avg(t.feedback_score) as avg_training_feedback
from employee_details e  
join training_programs t on e.employeeid= t.employeeid
group by e.department_id;

# 3. Evaluate the efficiency of project budgets by calculating costs per hour worked.

select  project_name, 
sum(hours_worked) as total_hours,
sum(budget) as total_budget,
(sum(budget)/sum(hours_worked)) as cost_per_hour
from project_assignments group by project_name;


# 4. Measure attendance trends and identify departments with significant deviations.

select e.department_id, sum(a.days_present) as total_days_present,
avg(a.days_present) as avg_days_present,
stddev(a.days_present) as dep_deviation
from employee_details e
join attendance_records a on e.employeeid = a.employeeid
group by e.department_id;

# 5. Link training technologies with project milestones to assess the real-world impact of training.

SELECT e.employeeid, e.employeename,
t.program_name AS training_program, t.technologies_covered,
p.project_name, p.technologies_used, p.milestones_achieved
FROM training_programs t
JOIN project_assignments p ON t.employeeid = p.employeeid
JOIN employee_details e ON e.employeeid = t.employeeid
ORDER BY p.milestones_achieved DESC;

# 6. Identify employees who significantly contribute to high-budget projects while 
#maintaining excellent performance scores.

select e.employeeid, e.employeename, e.performance_score,
 p.project_name, p.budget
from employee_details e 
join project_assignments p on e.employeeid = p.employeeid
where  e.performance_score = 'Excellent'
and p.budget > (select avg(p2.budget) from project_assignments p2)
order by p.budget desc;

# 7. Identify employees who have undergone training in specific 
#technologies and contributed to high-performing projects using those technologies.

SELECT e.employeeid, e.employeename,
t.program_name AS training_program, t.technologies_covered,
p.project_name, p.technologies_used, p.milestones_achieved
FROM training_programs t
JOIN project_assignments p ON t.employeeid = p.employeeid
JOIN employee_details e ON e.employeeid = t.employeeid
WHERE p.milestones_achieved >= 5  
AND p.technologies_used REGEXP REPLACE(t.technologies_covered, ', ', '|')
ORDER BY e.employeeid;
