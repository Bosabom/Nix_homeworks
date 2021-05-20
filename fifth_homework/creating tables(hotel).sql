CREATE TABLE Guest(
ID int not null primary key,
FIO nvarchar(200) not null,
Current_home_address nvarchar(200),
Birthday datetime
)


CREATE TABLE Room(
ID int not null primary key,
room_number int not null,
num_of_places int not null,
Category nvarchar(50) not null,
price_per_night money not null,
)


CREATE TABLE Registration_Journal(
ID int not null primary key,
GuestId int not null FOREIGN KEY REFERENCES Guest(ID),
RoomId int not null FOREIGN KEY REFERENCES Room(ID),
check_in_date datetime,
check_out_date datetime
)


CREATE TABLE Reservation(
ID int not null primary key,
GuestId int not null FOREIGN KEY REFERENCES Guest(ID),
RoomId int not null FOREIGN KEY REFERENCES Room(ID),
date_of_reservation datetime,
Booking_date_from datetime,
Booking_date_to datetime
)
