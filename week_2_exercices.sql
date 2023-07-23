USE little_lemon_db;

-- -------------------------------------------------------------------
-- Exercise: Create a virtual table to summarize data                |
-- -------------------------------------------------------------------

-- Task 1 
-- ---------------------------------------------

CREATE VIEW OrdersView AS
    SELECT 
        OrderID, Quantity, Cost
    FROM
        Orders;

select * from OrdersView;


-- Task 2
-- --------------------------------------------

SELECT 
    c.CustomerID,
    c.FullName,
    o.OrderID,
    o.TotalCost as Cost,
    m.MenuName,
    i.CourseName
FROM
    Costomers c
        INNER JOIN
    Orders o ON c.CustomerID = o.CustomerID
        INNER JOIN
    Menus m ON o.MenuID = m.MenuID
        INNER JOIN
    MenuItems i ON m.MenuItemID = i.MenuItemID;



-- Task 3 
-- ----------------------------------------------------

SELECT 
    MenuName
FROM
    Menus
WHERE
    MenuID = ANY (SELECT 
            MenuID
        FROM
            Orders
        WHERE
            Quantity > 2);
            


-- --------------------------------------------------------------------------------
-- Exercise: Create optimized queries to manage and analyze data                  |
-- --------------------------------------------------------------------------------

-- Task 1 
-- ------------------------------------------------------------

delimiter //
create procedure GetMaxQuantity()
begin
select max(quantity) as "Max Quantity in Orders" from orders;
end //
call GetMaxQuantity();

-- Task 2
-- ------------------------------------------------------------

prepare GetOrderDetail from "select OrderID, Quantity, Cost from Orders where OrderID = ?";
set @id = 5;
execute GetOrderDetail using @id;


-- Task 3
-- -------------------------------------------------------------

delimiter //
CREATE PROCEDURE CancelOrder(IN id INT)
BEGIN
DELETE FROM orders WHERE OrderID = id;
SELECT CONCAT("Order", " ", id, " ", "is cancelled") AS Confirmation;
end //
call CancelOrder(5);



-- --------------------------------------------------------------------
-- Create SQL queries to check available bookings based on user input  |
-- --------------------------------------------------------------------

-- Task 1
-- --------------------------------------------------------------------
INSERT INTO Bookings (BookingID, BookingDate, TableNumber, CustomerID)
VALUES
(1, "2022-10-10", 5,  1),
(2, "2022-11-12", 3, 3),
(3, "2022-10-11", 2, 2),
(4, "2022-10-13", 2, 1);


-- Task 2
-- ----------------------------------------------------------------
delimiter //
CREATE PROCEDURE CheckBooking (IN booking_date DATE, IN table_no INT)
BEGIN
	DECLARE nb_booking int;
    SELECT COUNT(BookingID) INTO nb_booking FROM Bookings WHERE BookingDate = booking_date AND TableNumber = table_no;
		IF nb_booking > 0
		THEN SELECT concat("Table", " ", table_no, " ", "is already booked") AS "Booking status";
            ELSE SELECT concat("Table", " ", table_no, " ", "is not booked yet") AS "Booking status";
            END IF;
END //

call CheckBooking("2022,11,12", 5);


-- Task 3
-- -------------------------------------------------------------------------

delimiter //
CREATE PROCEDURE AddValidBooking(in booking_date date, in table_no int)
BEGIN
	DECLARE nb_booking INT;
    START TRANSACTION;
    INSERT INTO Bookings(TableNumber, BookingDate) VALUES (table_no, booking_date);
	SELECT COUNT(BookingID) INTO nb_booking FROM Bookings WHERE BookingDate = booking_date AND TableNumber = table_no;
    IF nb_booking > 1
		THEN ROLLBACK;
        SELECT concat("Table", " ", table_no, " ", "is already booked - booking canceled") AS "Booking status"; 
	ELSE COMMIT;
        END IF;
END //

CALL AddValidBooking("2022-12-17", 7);





-- ----------------------------------------------------------
-- Exercise: Create SQL queries to add and update bookings   |
-- -----------------------------------------------------------

-- Task 1
-- ----------------------------------------------------------

DELIMITER //
CREATE PROCEDURE AddBooking(IN booking_id INT, IN table_no INT, IN customer_id INT, IN booking_date DATE)
BEGIN
	INSERT INTO Bookings (BookingID, TableNumber, BookingDate, CustomerID)
    VALUES
	(booking_id, table_no, booking_date, customer_id);
    SELECT "New booking added" AS Confirmation;
END //
CALL AddBooking(9, 3, 4, "2022-12-30");


-- Task 2
-- ----------------------------------------------------------------------

DELIMITER //
CREATE PROCEDURE UpdateBooking(IN booking_id INT, IN booking_date DATE)
BEGIN
	UPDATE Bookings SET BookingDate = booking_date WHERE BookingID = booking_id;
    SELECT CONCAT("Booking", " ", booking_id, " ", "updated") AS Confirmation;
END //

CALL UpdateBooking(9, "2022-12-17");



-- Task 3
-- -----------------------------------------------------------------

DELIMITER //
CREATE PROCEDURE CancelBooking(IN booking_id INT)
BEGIN
	DELETE FROM Bookings WHERE BookingID = booking_id;
    SELECT CONCAT("Booking", " ", booking_id, " ", "canceled") AS Confirmation;
END //

CALL CancelBooking(9);