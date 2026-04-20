create schema if not exists atyrau_library;

create table if not exists atyrau_library.books(
	book_id serial primary key,
	book_name varchar(100) not null, 
	publication_year DATE not null,
	ISBN char(13) unique not null
	);

create table if not exists atyrau_library.authors(
	author_id serial primary key,
	first_name VARCHAR(100) NOT null,
	last_name VARCHAR(100) NOT null,
	full_name varchar(100) GENERATED ALWAYS AS (first_name || ' ' || last_name) stored
);

create table if not exists atyrau_library.library_staff(
	staff_id serial primary key,
	first_name VARCHAR(100) NOT null,
	last_name VARCHAR(100) NOT null,
	birthdate date not null,
	job VARCHAR(15) not null,
	email varchar(100) not null unique,
	phone varchar(15) not null unique, 
	employment_date date not null
);


create table if not exists atyrau_library.borrowers(
	borrower_id serial primary key,
	first_name VARCHAR(100) NOT null,
	last_name VARCHAR(100) NOT null,
	email varchar(100) not null unique,
	phone varchar(15) not null unique, 
	registration_date date not null
);

create table if not exists atyrau_library.book_authors(
	book_id int REFERENCES atyrau_library.books(book_id), 
	author_id int REFERENCES atyrau_library.authors(author_id),
	primary key (book_id,author_id)
);

create table if not exists atyrau_library.reservations(
	reservation_id serial primary key,
	borrower_id int references atyrau_library.borrowers(borrower_id),
	book_id int REFERENCES atyrau_library.books(book_id),
	reservation_date date not null
);

create table if not exists atyrau_library.book_copies(
	copy_id serial primary key,
	book_id int REFERENCES atyrau_library.books(book_id),
	barcode char(13) not null unique,
	shelf varchar(50) not null,
	status VARCHAR(20) DEFAULT 'free'
);

create table if not exists atyrau_library.loans(
	loan_id serial primary key,
	loan_date date not null,
	due_date date not null,
	return_date date not null,
	borrower_id int references atyrau_library.borrowers(borrower_id),
	copy_id int references atyrau_library.book_copies(copy_id),
	staff_id int references atyrau_library.library_staff(staff_id)
);

create table if not exists atyrau_library.fines(
	fine_id serial primary key,
	loan_id int references  atyrau_library.loans(loan_id),
	fine_price decimal(10,2) not null,
	fine_date date not null,
	pay_due date not null
);

create table if not exists atyrau_library.genre(
	genre_id serial primary key,
	genre_name varchar(20) not null 
);

create table if not exists atyrau_library.book_genre(
	genre_id int references atyrau_library.genre(genre_id),
	book_id int references  atyrau_library.books(book_id),
	PRIMARY KEY (genre_id, book_id)
);

ALTER TABLE atyrau_library.fines 
DROP CONSTRAINT IF EXISTS fine_price_check;

ALTER TABLE atyrau_library.fines
ADD CONSTRAINT fine_price_check
CHECK (fine_price > 0);

ALTER TABLE atyrau_library.library_staff
DROP CONSTRAINT IF EXISTS employment_date_check;

ALTER TABLE atyrau_library.library_staff
ADD CONSTRAINT employment_date_check
CHECK (employment_date > birthdate);

ALTER TABLE atyrau_library.library_staff
DROP CONSTRAINT IF EXISTS staff_email_phone_unique;

ALTER TABLE atyrau_library.library_staff
ADD CONSTRAINT staff_email_phone_unique UNIQUE (email, phone);

ALTER TABLE atyrau_library.borrowers 
DROP CONSTRAINT IF EXISTS borrowers_email_phone_unique;

ALTER TABLE atyrau_library.borrowers 
ADD CONSTRAINT borrowers_email_phone_unique UNIQUE (email, phone);

ALTER TABLE atyrau_library.loans 
DROP CONSTRAINT IF EXISTS loan_date_check;

ALTER TABLE atyrau_library.loans
ADD CONSTRAINT loan_date_check
CHECK (due_date > loan_date);

ALTER TABLE atyrau_library.fines 
DROP CONSTRAINT IF EXISTS fine_date_check;

ALTER TABLE atyrau_library.fines
ADD CONSTRAINT fine_date_check
CHECK (pay_due> fine_date);

INSERT INTO atyrau_library.books (book_name, publication_year, ISBN ) VALUES 
('To Kill a Mockingbird','1990-07-11','1234567890123'),
('1984','1949-06-08','1234567890124'),
('The Great Gatsby','1925-04-10','1234567880124')
ON CONFLICT (ISBN) DO NOTHING;

insert into atyrau_library.authors (first_name, last_Name) VALUES
('Mark', 'Twen'),
('Osamu', 'Dazai'),
('Agatha', 'Christie');

insert into atyrau_library.reservations (reservation_date)
values 
('2026-04-15'),
('2026-04-24'),
('2026-05-02');

insert into atyrau_library.book_copies  (barcode, shelf, status) 
values 
('1234687412569', 'Fantasy', 'free'),
('1234647412569', 'Horroor', 'free'),
('1234687412569', 'Mystery', 'free')
ON CONFLICT (barcode) DO NOTHING;

insert into atyrau_library.loans (loan_date, due_date, return_date)
values
('2026-04-15', '2026-04-29', '2026-04-25'),
('2026-03-25', '2026-04-08', '2026-04-05'),
('2026-03-02', '2026-03-16', '2026-03-10');

insert into atyrau_library.fines (fine_price, fine_date, pay_due)
values 
('5.00', '2026-04-15', '2026-05-15'),
('15.00', '2026-03-29', '2026-04-29'),
('23.00', '2026-04-20', '2026-05-20');

insert into atyrau_library.library_staff (first_name, last_name, birthdate, job, email, phone, employment_date)
values 
('Bob', 'Ross', '1988-04-12','Librarian', 'bopross@gmail.com', '19831080397', '2025-05-16'),
('Robert', 'Paige', '1980-08-18','Librarian', 'RobrrtPaige@gmail.com', '19847040397', '2025-07-23'),
('Cass', 'Brook', '2005-12-18','Cleaner', 'cass_brooj@gmail.com', '19823440397', '2024-01-28')
ON CONFLICT (email, phone) DO NOTHING;


insert into atyrau_library.borrowers (first_name, last_name, email, phone, registration_date)
values 
('Vivian', 'Bush', 'vivianbush@gmail.com', '19823440397', '2025-05-16'),
('Vivian', 'Bush', 'vivianbush@gmail.com', '19823440397', '2025-05-16')
ON CONFLICT (email, phone) DO NOTHING;