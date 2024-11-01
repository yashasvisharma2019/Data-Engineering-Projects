-- Step 4.1: Write query to retrieve all customer information
SELECT *
FROM dbo.customers;
-- Step 4.2: Query accounts for a specific customer:
SELECT *
FROM dbo.accounts
WHERE customer_id = [customer_id];

--  Step 4.3: Find the customer name and account balance for each account
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    a.account_id,
    a.account_type,
    a.balance
FROM dbo.customers c
JOIN dbo.accounts a ON c.customer_id = a.customer_id;
--Step 4.4: Analyze customer loan balances:
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    COUNT(l.loan_id) AS number_of_loans,
    SUM(l.loan_amount) AS total_loan_amount
FROM dbo.customers c
LEFT JOIN dbo.loans l ON c.customer_id = l.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_loan_amount DESC;

-- Step 4.5: List all customers who have made a transaction in the 2024-03
SELECT DISTINCT
    c.customer_id,
    c.first_name,
    c.last_name
FROM dbo.customers c
JOIN dbo.accounts a ON c.customer_id = a.customer_id
JOIN dbo.transactions t ON a.account_id = t.account_id
WHERE t.transaction_date >= '2024-03-01' AND t.transaction_date < '2024-04-01'
ORDER BY c.customer_id;


--Step 5.1: Calculate the total balance across all accounts for each customer:
SELECT 
    c.customer_id,
    c.first_name,
    c.last_name,
    SUM(a.balance) AS total_balance
FROM dbo.customers c
LEFT JOIN dbo.accounts a ON c.customer_id = a.customer_id
GROUP BY c.customer_id, c.first_name, c.last_name
ORDER BY total_balance DESC;
--Step 5.2: Calculate the average loan amount for each loan term:
SELECT 
    loan_term,
    AVG(loan_amount) AS average_loan_amount,
    COUNT(*) AS number_of_loans
FROM dbo.loans
GROUP BY loan_term
ORDER BY loan_term;
--Step 5.3: Find the total loan amount and interest across all loans:
SELECT 
    SUM(loan_amount) AS total_loan_amount,
    SUM(loan_amount * (interest_rate / 100) * (loan_term / 12)) AS total_interest
FROM dbo.loans;
--Step 5.4: Find the most frequent transaction type
SELECT TOP 1
    transaction_type,
    COUNT(*) AS transaction_count
FROM dbo.transactions
GROUP BY transaction_type
ORDER BY transaction_count DESC;
--Step 5.5: Analyze transactions by account and transaction type:
SELECT 
    a.account_id,
    a.account_type,
    t.transaction_type,
    COUNT(*) AS transaction_count,
    SUM(t.transaction_amount) AS total_amount,
    AVG(t.transaction_amount) AS average_amount
FROM dbo.accounts a
JOIN dbo.transactions t ON a.account_id = t.account_id
GROUP BY a.account_id, a.account_type, t.transaction_type
ORDER BY a.account_id, total_amount DESC;

--Step 6.1: Create a view of active loans with payments greater than $1000:
CREATE VIEW vw_large_loan_payments AS
SELECT 
    l.loan_id,
    c.customer_id,
    c.first_name,
    c.last_name,
    l.loan_amount,
    l.interest_rate,
    l.loan_term,
    lp.payment_id,
    lp.payment_amount,
    lp.payment_date
FROM 
    dbo.loans l
JOIN 
    dbo.customers c ON l.customer_id = c.customer_id
JOIN 
    dbo.loan_payments lp ON l.loan_id = lp.loan_id
WHERE 
    lp.payment_amount > 1000
SELECT * FROM vw_large_loan_payments;
--Create an index on `transaction_date` in the `transactions` table for performance optimization:
CREATE INDEX IX_transactions_transaction_date
ON dbo.transactions (transaction_date);
