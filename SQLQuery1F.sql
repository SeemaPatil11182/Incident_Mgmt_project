use seema;

select * from INFORMATION_SCHEMA.TABLES;


create table EMPLOYEE(
employee_mail_id varchar(30) not null,
employee_id int not null,
employee_name varchar(30),
contact_number varchar(10),
password varchar(30) ,
primary key(employee_mail_id),
project_id int references PROJECT(project_id)
);

Insert into EMPLOYEE values('sam1@gmail.com',109300,'Sam',9449464827,'sam@123',100);
select * from EMPLOYEE;
drop table EMPLOYEE;


create table PROJECT(
project_id int not null,
project_name varchar(30) ,
department_name varchar(30),
location varchar(30),
workstation_number varchar(30),
extension_number varchar(30),
primary key(project_id)
);

Insert into PROJECT values(100,'Incident Management','testing','Pune','A11',3006);
select * from PROJECT;
drop table PROJECT;


Create table BUSINESS_FUNCTION_LOOKUP (
business_id int identity(1,1) primary key not null,
name varchar (30) not null);

Insert into BUSINESS_FUNCTION_LOOKUP values('Human Resource');
select * from BUSINESS_FUNCTION_LOOKUP;
drop table BUSINESS_FUNCTION_LOOKUP;

Create table SERVICE_LOOKUP(
service_id int identity(1,1)  primary key not null,
name varchar (30) not null,
business_id int,
Foreign key (business_id) references BUSINESS_FUNCTION_LOOKUP(business_id) );

Insert into SERVICE_LOOKUP values('HR Service',1);
select * from SERVICE_LOOKUP;
drop table SERVICE_LOOKUP;


Create table CATEGORY_LOOKUP(
category_id int identity(1,1)  primary key not null,
name varchar (30) not null,
service_id int,
Foreign key (service_id) references SERVICE_LOOKUP(service_id) );

Insert into CATEGORY_LOOKUP values('Employee data',1);
select * from CATEGORY_LOOKUP;
drop table CATEGORY_LOOKUP;

Create table INCIDENT_BUSINESS_FUNCTION_LOOKUP (
incident_business_id int identity(1,1) primary key not null,
name varchar (30) not null);

Insert into INCIDENT_BUSINESS_FUNCTION_LOOKUP values('ITIS');
select * from INCIDENT_BUSINESS_FUNCTION_LOOKUP;
drop table INCIDENT_BUSINESS_FUNCTION_LOOKUP;


Create table INCIDENT_SERVICE_LOOKUP(
incident_service_id int identity(1,1)  primary key not null,
name varchar (30) not null,
incident_business_id int,
Foreign key (incident_business_id) references INCIDENT_BUSINESS_FUNCTION_LOOKUP(incident_business_id) );

Insert into INCIDENT_SERVICE_LOOKUP values('network',1);
select * from INCIDENT_SERVICE_LOOKUP;
drop table INCIDENT_SERVICE_LOOKUP;

Create table INCIDENT_CATEGORY_LOOKUP(
incident_category_id int identity(1,1)  primary key not null,
name varchar (30) not null,
incident_service_id int,
Foreign key (incident_service_id) references INCIDENT_SERVICE_LOOKUP(incident_service_id) );

Insert into INCIDENT_CATEGORY_LOOKUP values('wireless',1);
select * from INCIDENT_CATEGORY_LOOKUP;
drop table INCIDENT_CATEGORY_LOOKUP;


create table INCIDENT_STATUS(
status_id int not null,
stage varchar(15) not null,
primary key(status_id)
);

Insert into INCIDENT_STATUS values(10,'processing');
select * from INCIDENT_STATUS;
drop table INCIDENT_STATUS;

create table INCIDENT_HANDLER(
handler_id int not null,
handler_name varchar(30) not null,
primary key(handler_id),
status_id int references INCIDENT_STATUS(status_id)
);

Insert into INCIDENT_HANDLER values(108222,'john',10);
select * from INCIDENT_HANDLER;
drop table INCIDENT_HANDLER;


CREATE table INCIDENT(
incident_id int identity(1,1) primary key not null,
incident_title varchar(30) not null,
incident_description varchar(60),
incident_category_id int references INCIDENT_CATEGORY_LOOKUP(incident_category_id),
category_id int references CATEGORY_LOOKUP(category_id),
handler_id  int references INCIDENT_HANDLER(handler_id),
raised_by varchar(30) not null references EMPLOYEE (employee_mail_id),
location varchar(30),
department varchar(30),
attachment varchar(50)
);

Insert into INCIDENT values('access to VPN','work from home',1,1,108222,'sam1@gmail.com','Bangalore','Testing','c:\user\sanket\documents');
select * from INCIDENT;
drop table INCIDENT;



--SP to save Profile Details
Create procedure save_employee
@employee_mail_id varchar (30) ,
@employee_id int ,
@employee_name varchar (30),
@contact_number varchar (10),
@project_id int ,
@project_name varchar(30),
@department_name varchar(30),
@location varchar(30),
@workstation_number varchar (30) ,
@extention_number varchar(30)
As begin try
Begin transaction save_transaction
if exists (select project_id from EMPLOYEE where employee_mail_id=@employee_mail_id)
begin
 update EMPLOYEE
 set employee_name=@employee_name,
 @employee_id=@employee_id,
 contact_number=@contact_number
 where employee_mail_id=@employee_mail_id
 print 'Employee table updated'
 update PROJECT
 set project_name=@project_name,
 department_name=@department_name,
 location=@location,
 workstation_number=@workstation_number,
 extension_number=@extention_number
 where project_id=(select project_id from EMPLOYEE where employee_mail_id=@employee_mail_id)
 print 'Project table updated'
end
else
begin
print 'Employee does not exists'
end
Commit transaction save_transaction
End try
Begin catch
Rollback transaction save_transaction
End catch 

exec save_employee @employee_mail_id ='seema1@gmail.com';

select * from save_employee;


Create procedure listincidents
@employee_mail_id varchar(30)
As begin 
Select I.incident_id ,I.incident_title from incident I 
Inner join employee e on e.employee_mail_id = I.raised_by 
Where I.raised_by = @employee_mail_id 
End 


create procedure track_incident
@incident_id int 
AS begin
Select ih.handler_name, s.stage as 'current status' from incident_status s
inner join incident_handler ih on s.status_id = ih.status_id
inner join incident i on i.handler_id = ih.handler_id 
where i.incident_id = @incident_id
End

sp_helptext track_incident