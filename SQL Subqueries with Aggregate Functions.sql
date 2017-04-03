

--QUESTION 1

--SUBQUERY SELECTS THE AVERAGE PRICE OF PRODUCTS
--FROM THE MERCHANDISE TABLE. WHERE HELPS IN LISTING MULTIPLE VALUES
--AS IT IS NEEDED HERE. THIS WHERE WILL COMPARE ITS VALUES (>) AGAINST
--THE AVG PRICE FOR ALL PRODUCT PRICES.

SELECT ItemID, Description, ListPrice AS [listprice]
FROM CIS310A8..Merchandise 
WHERE ListPrice >  (
						SELECT AVG(ListPrice)
						FROM CIS310A8..Merchandise
							
						)--nested query

--QUESTION 2

--THE DATA COMES FROM THE OrderItem, SalesItem, and Merchandise.
--INNER JOINS THROUGH FKs O.ItemID and SI.ItemID
--HAVING WILL COMPARE THE AVG (ListPrice + PLUS 50% MORE) WHETHER
--IT IS GREATER THAN THE AVG (Cost) 
--FROM THE OrderItem table
SELECT M.ItemID, AVG(O.Cost) AS [Average Cost], AVG(SI.SalePrice) AS [ Average Sale Price]--create a view
FROM CIS310A8..OrderItem O INNER JOIN CIS310A8..Merchandise M ON M.ItemID = O.ItemID
INNER JOIN CIS310A8..SaleItem SI ON SI.ItemID = M.ItemID
GROUP BY M.ItemID
HAVING AVG(SalePrice *(1+0.5)) > (
									SELECT AVG(Cost)
									FROM CIS310A8..OrderItem
								)--will only get 8 rows in correct answer


--CORRECTION
CREATE VIEW AVGCOST AS
SELECT OI.ItemID, AVG(OI.Cost) AS avgcost
FROM CIS310A8..OrderItem OI
GROUP BY OI.ItemID

CREATE VIEW AVGSALE AS
SELECT SI.ItemID, AVG(SI.SalePrice) AS avgsale
FROM CIS310A8..SaleItem SI
GROUP BY SI.ItemID


SELECT M.ItemID, M.Description, AVGCOST.avgcost, AVGSALE.avgsale
FROM AVGSALE INNER JOIN CIS310A8..Merchandise M ON M.ItemID = AVGSALE.ItemID
INNER JOIN AVGCOST ON M.ItemID = AVGCOST.ItemID
WHERE avgsale > (avgcost* 1.50)




--QUESTION 3

--create a view table to have the total sales, which come from
--sales quantity and sales price
CREATE VIEW SUM_EMP_SALES AS
SELECT E.EmployeeID, E.LastName, SUM(SI.SalePrice*SI.Quantity) AS TOTAL_SALES
FROM CIS310A8.. Employee E INNER JOIN CIS310A8..Sale S ON E.EmployeeID = S. EmployeeID
						INNER JOIN CIS310A8..SaleItem SI ON S.SaleID = SI.SaleID
GROUP BY E.EmployeeID, E.LastName
--after creating the view, create the query  to get the percentage. Run it, then create query
--after running the above query, you should see the following message, 
--"Command(s) completed successfully."

SELECT *, (TOTAL_SALES / (SELECT SUM(SalePrice * Quantity) FROM CIS310A8..SaleItem)) *100 AS PctSales
FROM SUM_EMP_SALES
ORDER BY EmployeeID


--QUESTION 4

CREATE VIEW PERCENTAGE_SHIP_COST AS --Command(s) completed successfully.
SELECT SU.SupplierID, SU.Name,  AVG(MO.ShippingCost/OI.Cost) AS PctShipCost
FROM CIS310A8..Supplier SU INNER JOIN CIS310A8..MerchandiseOrder MO ON SU.SupplierID = MO.SupplierID
INNER JOIN CIS310A8..OrderItem OI ON MO.PONumber = OI.PONumber
GROUP BY SU.SupplierID, SU.Name

--here, create a view table that will save the average percentage of shipping 
--cost of merchandise

SELECT SU.SupplierID, SU.Name, AVG(MO.ShippingCost/OI.Cost) AS PctShipCost
FROM CIS310A8..Supplier SU INNER JOIN CIS310A8..MerchandiseOrder MO ON SU.SupplierID = MO.SupplierID
INNER JOIN CIS310A8..OrderItem OI ON MO.PONumber = OI.PONumber
GROUP BY SU.SupplierID, SU.Name
HAVING AVG(MO.ShippingCost/OI.Cost) = (SELECT MAX(PctShipCost) FROM PERCENTAGE_SHIP_COST)

--when calling the view table, first go directly to the from clause
--in order to have its variables displayed by intellisense in other clauses
--will have the average percentage shipping cost
-- equal now to the maximun percentage shipping per cost




--QUESTION 5

CREATE VIEW MERCHANDISE_TOTAL AS
 --DONT FORGET TO CREATE THE VIEW HERE:Command(s) completed successfully.
SELECT C.CustomerID, C.LastName, C.FirstName, SUM(SI.SalePrice*SI.Quantity) AS MERCTOTAL
FROM CIS310A8..SaleItem SI INNER JOIN CIS310A8..Sale S ON S.SaleID = SI.SaleID
INNER JOIN CIS310A8..SaleAnimal SA ON S.SaleID = SA.SaleID
INNER JOIN CIS310A8..Animal A ON A.AnimalID = SA.AnimalID
INNER JOIN CIS310A8..Customer C ON C.CustomerID = S.CustomerID 
GROUP BY C.CustomerID, C.LastName, C.FirstName
HAVING SUM(SI.SalePrice*SI.Quantity)>(SELECT MAX(TEMP.[TOTAL SALE ITEMS]) AS MERCTOTAL
										FROM (
											SELECT SUM(SI.SalePrice*SI.Quantity) AS [TOTAL SALE ITEMS]
											FROM CIS310A8..SaleItem SI
											GROUP BY SaleID
											)TEMP
											)

CREATE VIEW ANIMAL_TOTAL AS
--now make the table for the animal total: Command(s) completed successfully.
SELECT C.CustomerID, C.LastName, C.FirstName, SUM(SA.SalePrice) AS AnimalTotal
FROM CIS310A8..SaleItem SI INNER JOIN CIS310A8..Sale S ON S.SaleID = SI.SaleID
INNER JOIN CIS310A8..SaleAnimal SA ON S.SaleID = SA.SaleID
INNER JOIN CIS310A8..Animal A ON A.AnimalID = SA.AnimalID
INNER JOIN CIS310A8..Customer C ON C.CustomerID = S.CustomerID 
GROUP BY C.CustomerID, C.LastName, C.FirstName
HAVING SUM(SA.SalePrice)>(
							SELECT MAX(TEMP.[ANIMAL TOTAL]) AS AnimalTotal
							FROM (
									SELECT SUM(SA.SalePrice) AS [ANIMAL TOTAL]
									FROM CIS310A8..SaleAnimal SA
									GROUP BY SA.SaleID
								)TEMP
						)


--NOW CREATE THE TABLE TO UNITY ANIMAL AND MERCHANSIDE GRAND TOTAL: Command(s) completed successfully.
CREATE VIEW ANIMAL_AND_MERCHANDISE_TABLE AS
SELECT AT.CustomerID, AT.LastName, AT.FirstName, MT.MERCTOTAL, AT.AnimalTotal, (MT.MERCTOTAL + AT.AnimalTotal) AS GrandTotal
FROM ANIMAL_TOTAL AT INNER JOIN MERCHANDISE_TOTAL MT ON AT.CustomerID = MT.CustomerID
GROUP BY AT.CustomerID, AT.LastName, AT.FirstName, MT.MERCTOTAL, AT.AnimalTotal


										
SELECT *
FROM ANIMAL_AND_MERCHANDISE_TABLE
WHERE GrandTotal = (
					SELECT MAX(GrandTotal)
					FROM ANIMAL_AND_MERCHANDISE_TABLE
				
					)



--QUESTION 6

SELECT C.CustomerID, C.LastName, C.FirstName, SUM(SI.Quantity*SI.SalePrice) AS MayTotal
FROM CIS310A8..Customer C INNER JOIN CIS310A8..Sale S ON C.CustomerID = S.CustomerID
INNER JOIN CIS310A8..SaleItem SI ON S.SaleID= SI.SaleID
WHERE C.CustomerID IN(
						SELECT C.CustomerID
						FROM CIS310A8..Customer C INNER JOIN CIS310A8..Sale S ON C.CustomerID = S.CustomerID
						INNER JOIN CIS310A8..SaleItem SI ON S.SaleID= SI.SaleID
						WHERE C.CustomerID = S.CustomerID AND S.SaleDate LIKE '%OCT%'
						GROUP BY C.CustomerID, C.LastName, C.FirstName, S.SaleDate
						HAVING SUM(SI.Quantity*SI.SalePrice) > 50
						)
					AND S.SaleDate LIKE '%MAY%'
					GROUP BY C.CustomerID, C.LastName, C.FirstName
					HAVING SUM(SI.SalePrice * SI.Quantity) > 100


--QUESTION 7

--only merchandise
--item id for premium canned dog food is 16. use this for where when looking
--for this specific item.
SELECT M.Description, M.ItemID, SUM(OI.Quantity) AS Purchased, SUM(SI.Quantity) AS Sold, SUM(M.QuantityOnHand / SI.Quantity) AS NetIncrease
FROM CIS310A8..OrderItem OI INNER JOIN CIS310A8..Merchandise M ON M.ItemID = OI.ItemID
							INNER JOIN CIS310A8..SaleItem SI ON SI.ItemID = M.ItemID
							INNER JOIN CIS310A8..Sale S ON S.SaleID = SI.SaleID
WHERE M.ItemID = 16 AND S.SaleDate BETWEEN '1-JAN-2004' AND '1-JUL-2004'
GROUP BY M.Description, M.ItemID




--QUESTION 8

SELECT DISTINCT M.ItemID, M.Description, M.ListPrice
FROM CIS310A8..Sale S INNER JOIN CIS310A8..SaleItem SI ON S.SaleID = SI.SaleID--left join
INNER JOIN CIS310A8..Merchandise M ON M.ItemID = SI.ItemID
WHERE M.ListPrice > 50 AND S.SaleDate NOT LIKE '%JUL%'
ORDER BY M.ItemID

--QUESTION 9

SELECT M.ItemID, M.Description, M.QuantityOnHand, OI.ItemID
FROM CIS310A8..Merchandise M LEFT OUTER JOIN CIS310A8..OrderItem OI ON M.ItemID = OI.ItemID
LEFT OUTER JOIN CIS310A8..MerchandiseOrder MO ON MO.PONumber = OI.PONumber
WHERE M.QuantityOnHand > 100 AND MO.OrderDate IS NULL
ORDER BY M.ItemID
--since all orders were put in 2004,
--to show those orders, have OrderDate that is null




--QUESTION 10

--because an item is not merchandise until it is in the
--merchandise table, look for the itemid that was not
--ordered in the itemorder table. operator AND looks for quantity
SELECT M.ItemID, M.Description, M.QuantityOnHand, M.ItemID
FROM cis310A8..Merchandise M 
WHERE M.ItemID NOT IN(
							SELECT OI.ItemID
							FROM CIS310A8..OrderItem OI--call the table 1st, to have is attribute
						)
						AND
						M.QuantityOnHand > 100


-- QUESTION 11




CREATE TABLE CATEGORY--Command(s) completed successfully.

(
	CATEGORY VARCHAR (10) NOT NULL,
	LOW MONEY NOT NULL,
	HIGH MONEY NOT NULL

)



--populate the category table
INSERT INTO CATEGORY
(CATEGORY, LOW, HIGH) VALUES ('WEAK', 0, 200);

INSERT INTO CATEGORY
(CATEGORY, LOW, HIGH) VALUES ('GOOD', 200, 800);

INSERT INTO CATEGORY
(CATEGORY, LOW, HIGH ) VALUES ('BEST', 800, 10000);



SELECT *
FROM ANIMAL_AND_MERCHANDISE_TABLE
WHERE GrandTotal = (
					SELECT MAX(GrandTotal)
					FROM ANIMAL_AND_MERCHANDISE_TABLE
				
					)
					



--QUESTION 12

SELECT SU.Name AS [Supplier Name], 'Merchandise' AS OrderType
FROM CIS310A8..Supplier SU INNER JOIN CIS310A8..MerchandiseOrder MO ON SU.SupplierID = MO.SupplierID
INNER JOIN CIS310A8..OrderItem OI ON MO.PONumber = OI.PONumber
GROUP BY SU.Name, SU.SupplierID, OI.Cost
HAVING OI.Cost > 0 AND SU.SupplierID IN (
											SELECT MO.SupplierID
											FROM CIS310A8..MerchandiseOrder MO
											WHERE OrderDate BETWEEN '2004-06-01' AND '2004-06-30'
											GROUP BY MO.SupplierID
										)

										UNION
										--unify the two tables
SELECT SU.SupplierID AS [Supplier Name], 'Animal' AS OrderYpe
FROM CIS310A8..Supplier SU INNER JOIN CIS310A8..AnimalOrder AO ON SU.SupplierID = AO.SupplierID
INNER JOIN CIS310A8..AnimalOrderItem AI ON AO.OrderID = AI.OrderID
GROUP BY SU.Name, SU.SupplierID, AI.Cost
HAVING AI.Cost > 0 AND SU.SupplierID IN (
											SELECT AO.SupplierID
											FROM CIS310A8..AnimalOrder AO
											WHERE OrderDate BETWEEN '2004-06-01' AND '2004-06-30'
											GROUP BY AO.SupplierID
										)
										--error: Conversion failed when converting the nvarchar value 'Harrison' to data type int.

-- QUESTION 13
UPDATE CATEGORY
SET HIGH = 400
WHERE CATEGORY LIKE '400'


--QUESTION 14
DROP TABLE CATEGORY


--QUESTION 15

DELETE 
FROM CATEGORY
WHERE CATEGORY = 'WEAK'

--QUESTION 16
SELECT *
INTO EMPLOYEE_DUPLICATE
FROM CIS310A8..Employee

DELETE
FROM EMPLOYEE_DUPLICATE

INSERT
INTO EMPLOYEE_DUPLICATE
SELECT *
FROM CIS310A8..Employee
