-- =====================================================
-- EPAM SQL DML HOMEWORK
-- Author: Luisa Alvarez
-- Database: BANK
-- Schema: PUBLIC
-- =====================================================

USE DATABASE BANK;
USE SCHEMA PUBLIC;

-- =====================================================
-- CATEGORY 1: SIMPLE QUESTIONS
-- PROBLEM 1: Display Customer Information Sorted by Birth Year
-- =====================================================

SELECT
     custid,
     fname,
     dob
FROM CUSTOMER
ORDER BY 
    EXTRACT(YEAR FROM dob),
    fname;

-- =====================================================
-- CATEGORY 1: SIMPLE QUESTIONS
-- PROBLEM 2: Display Customer Name Based on Middle Name
-- =====================================================

SELECT
    custid,
    fname,
    CASE
        WHEN mname IS NULL THEN ltname
        ELSE mname
    END AS Cust_Name
FROM CUSTOMER;

-- =====================================================
-- CATEGORY 1: SIMPLE QUESTIONS
-- PROBLEM 3: Display Account and Customer Information
-- INNER JOIN returns only accounts that have a matching customer.
-- =====================================================

SELECT
    ac.acnumber,
    ac.custid,
    cu.fname,
    cu.ltname,
    ac.aod
FROM CUSTOMER cu
INNER JOIN ACCOUNT ac
on ac.custid = cu.custid;

-- =====================================================
-- CATEGORY 1: SIMPLE QUESTIONS
-- PROBLEM 4: Count Customers in Delhi
-- =====================================================

SELECT
    COUNT(*) AS Cust_Count
FROM CUSTOMER
WHERE city = 'Delhi';

-- =====================================================
-- CATEGORY 1: SIMPLE QUESTIONS
-- PROBLEM 5: Display Accounts Opened After the 15th Day of the Month
-- INNER JOIN returns only accounts associated with existing customers.
-- =====================================================

SELECT
    cu.custid,
    cu.fname,
    ac.acnumber
FROM CUSTOMER cu
INNER JOIN ACCOUNT ac
ON ac.custid = cu.custid
WHERE EXTRACT (DAY FROM ac.aod) > 15;

-- =====================================================
-- CATEGORY 1: SIMPLE QUESTIONS
-- PROBLEM 6: Display Female Customers and Their Accounts
-- INNER JOIN returns only customers who have at least one associated account.
-- The CUSTOMER table does not contain a SEX or GENDER column.
-- Therefore, female customers cannot be directly identified using the available schema.
-- The OCCUPATION column is used as an alternative criterion to exclude
-- Business, Service, and Student occupations, as specified in the exercise.
-- This approach does not guarantee that all selected customers are female.
-- =====================================================

SELECT 
    cu.fname,
    cu.city,
    ac.acnumber
FROM CUSTOMER cu
INNER JOIN ACCOUNT ac
ON cu.custid = ac.custid
WHERE cu.occupation NOT IN ('Service', 'Business', 'Student');

-- =====================================================
-- CATEGORY 1: SIMPLE QUESTIONS
-- PROBLEM 7: Count Branches by City
-- =====================================================

SELECT
    bcity,
    COUNT(*) AS Count_Branch
FROM BRANCH
GROUP BY bcity;

-- =====================================================
-- CATEGORY 1: SIMPLE QUESTIONS
-- PROBLEM 8: Display Customers with Active Accounts
-- INNER JOIN returns only customers with matching accounts.
-- The WHERE clause further filters the result to active accounts.
-- =====================================================

SELECT
    ac.acnumber,
    cu.fname,
    cu.ltname
FROM CUSTOMER cu
INNER JOIN ACCOUNT ac
ON ac.custid = cu.custid
WHERE ac.astatus = 'Active';

-- =====================================================
-- CATEGORY 1: SIMPLE QUESTIONS
-- PROBLEM 9: Display Customers Who Have Taken Loans
-- INNER JOIN returns only customers who have a matching loan record.
-- =====================================================

SELECT
    cu.custid,
    cu.fname,
    lo.bid,
    lo.loan_amount
FROM CUSTOMER cu
INNER JOIN LOAN lo
ON cu.custid = lo.custid;

-- =====================================================
-- CATEGORY 1: SIMPLE QUESTIONS
-- PROBLEM 10: Display Customers with Terminated Accounts
-- INNER JOIN returns only customers with matching accounts.
-- The WHERE clause further filters the result to terminated accounts.
-- =====================================================

SELECT
    cu.custid,
    cu.fname,
    ac.acnumber
FROM CUSTOMER cu
INNER JOIN ACCOUNT ac
ON ac.custid = cu.custid
WHERE ac.astatus = 'Terminated';

-- =====================================================
-- CATEGORY 2: MEDIUM COMPLEXITY QUESTIONS
-- PROBLEM 1: Count Deposits and Withdrawals by Customer
-- INNER JOIN returns only transactions associated with an existing account.
-- The second INNER JOIN keeps only accounts associated with an existing customer.
-- =====================================================

SELECT 
    td.transaction_type,
    count(*) AS Trans_Count
FROM trandetails td
INNER JOIN account ac
ON td.acnumber = ac.acnumber
INNER JOIN customer cu 
ON ac.custid = cu.custid
WHERE cu.custid = 'C00001'
GROUP BY td.transaction_type;

-- =====================================================
-- CATEGORY 2: MEDIUM COMPLEXITY QUESTIONS
-- PROBLEM 2: Display Customers with Accounts in Different Cities
-- The first INNER JOIN returns customers with matching accounts.
-- The second INNER JOIN keeps only accounts associated with an existing branch.
-- =====================================================

SELECT
    cu.custid,
    cu.fname,
    cu.city,
    br.bcity
FROM CUSTOMER cu
INNER JOIN ACCOUNT ac
ON cu.custid = ac.custid
INNER JOIN BRANCH br
ON ac.bid = br.bid
WHERE br.bcity <> cu.city;

-- =====================================================
-- CATEGORY 2: MEDIUM COMPLEXITY QUESTIONS
-- PROBLEM 3: Display Customers with Loans from Multiple Branches
-- INNER JOIN returns only customers who have at least one loan.
-- =====================================================

SELECT
    cu.custid,
    cu.fname,
    cu.ltname
FROM CUSTOMER cu
INNER JOIN LOAN lo
ON cu.custid = lo.custid
GROUP BY cu.custid, cu.fname, cu.ltname
HAVING COUNT(DISTINCT lo.bid) > 1;

-- =====================================================
-- CATEGORY 2: MEDIUM COMPLEXITY QUESTIONS
-- PROBLEM 4: Count Customers with Loans but No Accounts
-- INNER JOIN ensures that only customers with loans are considered.
-- LEFT JOIN preserves these customers even when they have no accounts.
-- WHERE IS NULL identifies customers without a matching account.
-- =====================================================

SELECT
    COUNT(DISTINCT cu.custid) AS Count
FROM CUSTOMER cu
INNER JOIN LOAN lo
ON cu.custid = lo.custid
LEFT JOIN ACCOUNT ac
ON cu.custid = ac.custid
WHERE ac.custid IS NULL;

-- =====================================================
-- CATEGORY 2: MEDIUM COMPLEXITY QUESTIONS
-- PROBLEM 5: Calculate Total Deposit Amount by Account
-- LEFT JOIN preserves all accounts, including those without deposit transactions.
-- The transaction type condition in ON prevents accounts without deposits from being excluded.
-- =====================================================

SELECT
    ac.acnumber,
    COALESCE(SUM(tr.transaction_amount), 0)
        + ac.opening_balance AS Deposit_Amount
FROM ACCOUNT AS ac
LEFT JOIN TRANDETAILS AS tr
    ON ac.acnumber = tr.acnumber
    AND tr.transaction_type = 'Deposit'
GROUP BY
    ac.acnumber,
    ac.opening_balance;

-- =====================================================
-- CATEGORY 2: MEDIUM COMPLEXITY QUESTIONS
-- PROBLEM 6: Count Registered Customers Without Accounts
-- LEFT JOIN preserves all registered customers, including those without accounts.
-- WHERE IS NULL identifies customers without a matching account.
-- =====================================================

SELECT
    COUNT(DISTINCT cu.custid) AS Count_Customer
FROM CUSTOMER cu
LEFT JOIN ACCOUNT ac
ON cu.custid = ac.custid
WHERE ac.custid IS NULL;

-- =====================================================
-- CATEGORY 2: MEDIUM COMPLEXITY QUESTIONS
-- PROBLEM 7: Count Accounts by City and Branch
-- LEFT JOIN preserves all branches, including those without accounts.
-- COUNT(ac.acnumber) returns zero for branches without matching accounts.
-- =====================================================

SELECT
    br.bcity,
    br.bname,
    COUNT(ac.acnumber) AS Account_Count
FROM BRANCH AS br
LEFT JOIN ACCOUNT AS ac
    ON br.bid = ac.bid
GROUP BY
    br.bcity,
    br.bname;

-- =====================================================
-- CATEGORY 2: MEDIUM COMPLEXITY QUESTIONS
-- PROBLEM 8: Display Customers with More Than One Account
-- INNER JOIN returns only customers who have at least one account.
-- =====================================================

SELECT
    cu.fname
FROM CUSTOMER AS cu
INNER JOIN ACCOUNT AS ac
    ON cu.custid = ac.custid
GROUP BY
    cu.custid,
    cu.fname
HAVING COUNT(DISTINCT ac.acnumber) > 1;

-- =====================================================
-- CATEGORY 2: MEDIUM COMPLEXITY QUESTIONS
-- PROBLEM 9: Display Customers with Multiple Accounts Across Multiple Branches
-- The first INNER JOIN keeps customers with associated accounts.
-- The second INNER JOIN keeps accounts associated with an existing branch.
-- =====================================================

SELECT
    cu.fname
FROM CUSTOMER cu
INNER JOIN ACCOUNT ac
ON ac.custid = cu.custid
INNER JOIN BRANCH br
ON ac.bid = br.bid
GROUP BY
    cu.custid,
    cu.fname
HAVING COUNT(DISTINCT ac.acnumber) > 1 AND COUNT(DISTINCT br.bid) > 1;

-- =====================================================
-- CATEGORY 2: MEDIUM COMPLEXITY QUESTIONS
-- PROBLEM 10: Count Transactions by Customer and Account
-- The first INNER JOIN keeps customers with matching accounts.
-- The second INNER JOIN keeps only accounts with at least one transaction.
-- =====================================================

SELECT
    cu.custid,
    cu.fname,
    ac.acnumber,
    COUNT(DISTINCT tr.tnumber) AS Count_Trans
FROM CUSTOMER AS cu
INNER JOIN ACCOUNT AS ac
    ON cu.custid = ac.custid
INNER JOIN TRANDETAILS AS tr
    ON ac.acnumber = tr.acnumber
GROUP BY
    cu.custid,
    cu.fname,
    ac.acnumber;

-- =====================================================
-- CATEGORY 3: COMPLEX QUESTIONS
-- PROBLEM 1: Find the Account with the Highest Number of Transactions
-- =====================================================

SELECT
    tr.acnumber
FROM TRANDETAILS tr
GROUP BY tr.acnumber
ORDER BY COUNT(DISTINCT tnumber) DESC
LIMIT 1;

-- =====================================================
-- CATEGORY 3: COMPLEX QUESTIONS
-- PROBLEM 2: Find the Branch with the Highest Number of Customers
-- INNER JOIN returns only branches with at least one associated account.
-- =====================================================

SELECT
    br.bname,
    br.bcity
FROM BRANCH AS br
INNER JOIN ACCOUNT AS ac
    ON br.bid = ac.bid
GROUP BY
    br.bid,
    br.bname,
    br.bcity
ORDER BY
    COUNT(DISTINCT ac.custid) DESC
LIMIT 1;

-- =====================================================
-- CATEGORY 3: COMPLEX QUESTIONS
-- PROBLEM 3: Calculate Account Balance Including Opening Balance
-- LEFT JOIN preserves the account even if it has no transactions.
-- This allows the opening balance to be included without transaction records.
-- =====================================================

SELECT
    ac.opening_balance
        + COALESCE(
            SUM(
                CASE
                    WHEN tr.transaction_type = 'Deposit'
                    THEN tr.transaction_amount
                    WHEN tr.transaction_type = 'Withdrawal'
                    THEN -tr.transaction_amount
                    ELSE 0
                END
            ), 0
        ) AS Balance
FROM ACCOUNT AS ac
LEFT JOIN TRANDETAILS AS tr
    ON ac.acnumber = tr.acnumber
WHERE ac.acnumber = 'A00001'
GROUP BY
    ac.acnumber,
    ac.opening_balance;

-- =====================================================
-- CATEGORY 3: COMPLEX QUESTIONS
-- PROBLEM 4: Find Accounts Where Withdrawals Exceed Deposits
-- LEFT JOIN preserves all accounts, including those without transactions.
-- This allows accounts without transaction records to remain in the result set.
-- =====================================================

SELECT
    ac.acnumber,
    SUM(
        CASE
            WHEN tr.transaction_type = 'Deposit'
            THEN tr.transaction_amount
            ELSE 0
        END
    ) AS Deposit,
    SUM(
        CASE
            WHEN tr.transaction_type = 'Withdrawal'
            THEN tr.transaction_amount
            ELSE 0
        END
    ) AS Withdrawal
FROM ACCOUNT AS ac
LEFT JOIN TRANDETAILS AS tr
    ON ac.acnumber = tr.acnumber
GROUP BY
    ac.acnumber
HAVING
    SUM(
        CASE
            WHEN tr.transaction_type = 'Withdrawal'
            THEN tr.transaction_amount
            ELSE 0
        END
    ) >
    SUM(
        CASE
            WHEN tr.transaction_type = 'Deposit'
            THEN tr.transaction_amount
            ELSE 0
        END
    );

-- =====================================================
-- CATEGORY 3: COMPLEX QUESTIONS
-- PROBLEM 5: Find Customer with the Highest Total Loan Amount Across at Least Two Branches
-- INNER JOIN returns only customers who meet the loan criteria calculated in the CTE.
-- Customers without a qualifying loan record are excluded.
-- =====================================================

WITH SEVERAL_BANKS_LOAN AS (
    SELECT
        lo.custid,
        SUM(lo.loan_amount) AS Total_Loan_Amount
    FROM LOAN AS lo
    GROUP BY
        lo.custid
    HAVING COUNT(DISTINCT lo.bid) >= 2
)
SELECT
    cu.custid,
    cu.fname,
    cu.ltname
FROM CUSTOMER AS cu
INNER JOIN SEVERAL_BANKS_LOAN AS sv
    ON cu.custid = sv.custid
ORDER BY
    sv.Total_Loan_Amount DESC
LIMIT 1;