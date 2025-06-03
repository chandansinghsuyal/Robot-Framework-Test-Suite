*** Settings ***
Documentation    Database testing scenarios for e-commerce application
Library          DatabaseLibrary
Library          Collections
Library          String
Resource         ../resources/api/api_keywords.robot
Resource         ../resources/test_data.robot

*** Variables ***
${DB_HOST}        localhost
${DB_PORT}        5432
${DB_NAME}        ecommerce
${DB_USER}        postgres
${DB_PASSWORD}    postgres

*** Test Cases ***
Test Database Connection
    [Documentation]    Test database connection and basic operations
    [Tags]    database
    Connect To Database    psycopg2    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    ${result}=    Query    SELECT version();
    Should Not Be Empty    ${result}
    [Teardown]    Disconnect From Database

Test Product Data Integrity
    [Documentation]    Test product data integrity
    [Tags]    database
    Connect To Database    psycopg2    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    
    # Test product table structure
    ${columns}=    Query    SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'products';
    ${expected_columns}=    Create List
    ...    id    integer
    ...    name    character varying
    ...    price    numeric
    ...    category    character varying
    ...    description    text
    ...    stock    integer
    ...    created_at    timestamp
    ...    updated_at    timestamp
    
    FOR    ${column}    IN    @{columns}
        List Should Contain Value    ${expected_columns}    ${column}[0]
    END
    
    # Test product data constraints
    ${result}=    Query    SELECT COUNT(*) FROM products WHERE price < 0;
    Should Be Equal As Numbers    ${result}[0][0]    0    Products with negative price found
    
    ${result}=    Query    SELECT COUNT(*) FROM products WHERE stock < 0;
    Should Be Equal As Numbers    ${result}[0][0]    0    Products with negative stock found
    
    [Teardown]    Disconnect From Database

Test Order Data Integrity
    [Documentation]    Test order data integrity
    [Tags]    database
    Connect To Database    psycopg2    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    
    # Test order table structure
    ${columns}=    Query    SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'orders';
    ${expected_columns}=    Create List
    ...    id    integer
    ...    user_id    integer
    ...    total_amount    numeric
    ...    status    character varying
    ...    created_at    timestamp
    ...    updated_at    timestamp
    
    FOR    ${column}    IN    @{columns}
        List Should Contain Value    ${expected_columns}    ${column}[0]
    END
    
    # Test order status values
    ${result}=    Query    SELECT DISTINCT status FROM orders;
    ${valid_statuses}=    Create List    pending    processing    completed    cancelled
    FOR    ${status}    IN    @{result}
        List Should Contain Value    ${valid_statuses}    ${status}[0]
    END
    
    [Teardown]    Disconnect From Database

Test User Data Integrity
    [Documentation]    Test user data integrity
    [Tags]    database
    Connect To Database    psycopg2    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    
    # Test user table structure
    ${columns}=    Query    SELECT column_name, data_type FROM information_schema.columns WHERE table_name = 'users';
    ${expected_columns}=    Create List
    ...    id    integer
    ...    username    character varying
    ...    email    character varying
    ...    password    character varying
    ...    role    character varying
    ...    created_at    timestamp
    ...    updated_at    timestamp
    
    FOR    ${column}    IN    @{columns}
        List Should Contain Value    ${expected_columns}    ${column}[0]
    END
    
    # Test email uniqueness
    ${result}=    Query    SELECT email, COUNT(*) FROM users GROUP BY email HAVING COUNT(*) > 1;
    Should Be Empty    ${result}    Duplicate email addresses found
    
    [Teardown]    Disconnect From Database

Test Database Performance
    [Documentation]    Test database performance
    [Tags]    database    performance
    Connect To Database    psycopg2    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    
    # Test query performance
    ${queries}=    Create List
    ...    SELECT * FROM products WHERE category = 'electronics'
    ...    SELECT * FROM orders WHERE status = 'completed'
    ...    SELECT * FROM users WHERE role = 'customer'
    ...    SELECT p.*, o.total_amount FROM products p JOIN order_items oi ON p.id = oi.product_id JOIN orders o ON oi.order_id = o.id
    
    FOR    ${query}    IN    @{queries}
        ${start_time}=    Get Current Date
        ${result}=    Query    ${query}
        ${end_time}=    Get Current Date
        ${execution_time}=    Evaluate    ${end_time} - ${start_time}
        Should Be True    ${execution_time} <= 1.0    Query execution time too high: ${query}
    END
    
    [Teardown]    Disconnect From Database

Test Database Indexes
    [Documentation]    Test database indexes
    [Tags]    database
    Connect To Database    psycopg2    ${DB_NAME}    ${DB_USER}    ${DB_PASSWORD}    ${DB_HOST}    ${DB_PORT}
    
    # Test required indexes
    ${indexes}=    Query    SELECT indexname, indexdef FROM pg_indexes WHERE tablename IN ('products', 'orders', 'users');
    ${required_indexes}=    Create List
    ...    products_category_idx
    ...    products_price_idx
    ...    orders_user_id_idx
    ...    orders_status_idx
    ...    users_email_idx
    ...    users_username_idx
    
    FOR    ${index}    IN    @{indexes}
        List Should Contain Value    ${required_indexes}    ${index}[0]
    END
    
    [Teardown]    Disconnect From Database

*** Keywords ***
Get Current Date
    ${date}=    Get Current Date    result_format=epoch
    [Return]    ${date} 