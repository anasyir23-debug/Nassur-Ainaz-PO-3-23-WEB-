CREATE TABLE owners (
  Owner_ID SERIAL PRIMARY KEY,
  FIRST_NAME VARCHAR(20) NOT NULL,
  Last_Name VARCHAR(20) NOT NULL,
  birthdate DATE NOT NULL,
  email VARCHAR(50) NOT NULL UNIQUE,
  number VARCHAR(15) NOT NULL UNIQUE,
  address VARCHAR(50) NOT NULL
);

CREATE TABLE pets (
  Pet_ID SERIAL PRIMARY KEY,
  Pet_Name VARCHAR(20) NOT NULL,
  Owner_ID INT NOT NULL,
  BIRTHDATE DATE NOT NULL,
  FOREIGN KEY (Owner_ID) REFERENCES owners(Owner_ID)
);

CREATE TABLE vets (
  Vet_ID SERIAL PRIMARY KEY,
  FIRST_NAME VARCHAR(20) NOT NULL,
  Last_Name VARCHAR(20) NOT NULL,
  birthdate DATE NOT NULL,
  email VARCHAR(50) NOT NULL UNIQUE,
  number VARCHAR(15) NOT NULL UNIQUE,
  address VARCHAR(50) NOT NULL,
  employment_date DATE NOT NULL
);

CREATE TABLE reservation (
  Reservation_ID SERIAL PRIMARY KEY,
  Reservation_Room INT NOT NULL,
  Pet_ID INT NOT NULL,
  Vet_ID INT NOT NULL,
  Appointment_Time TIMESTAMP NOT NULL,
  FOREIGN KEY (Pet_ID) REFERENCES pets(Pet_ID),
  FOREIGN KEY (Vet_ID) REFERENCES vets(Vet_ID)
);

INSERT INTO owners (FIRST_NAME, Last_Name, birthdate, email, number, address) VALUES 
('John','Doe','1990-01-01','john@email.com','12345678','Street 1'),
('Anna','Smith','1995-02-02','anna@email.com','98765432','Street 2'),
('Mike','Brown','1988-03-03','mike@email.com','55566677','Street 3');

INSERT INTO pets (Pet_Name, Owner_ID, BIRTHDATE) VALUES 
('Bingo',1,'2026-02-05'),
('Chilly',2,'2024-05-06'),
('Bluey',3,'2025-08-15');

INSERT INTO vets (FIRST_NAME, Last_Name, birthdate, email, number, address, employment_date) VALUES 
('John','Doe','1990-01-01','jogn@email.com','12346678','Street 1','2026-02-05'),
('Anna','Smith','1995-02-02','anda@email.com','98465432','Street 2','2015-04-18'),
('Mike','Brown','1988-03-03','miki@email.com','55516677','Street 3','2010-12-29');

INSERT INTO reservation (Reservation_Room, Pet_ID, Vet_ID, Appointment_Time) VALUES
(101,1,1,'2026-04-15 14:30:00'),
(102,2,2,'2026-04-17 16:30:00'),
(103,3,3,'2026-04-21 12:30:00');