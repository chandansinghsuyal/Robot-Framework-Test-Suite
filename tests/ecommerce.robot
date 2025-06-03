*** Settings ***
Documentation    E-commerce end-to-end test suite
Library          SeleniumLibrary
Library          RequestsLibrary
Library          Collections
Resource         ../resources/ui/common/common_keywords.robot
Resource         ../resources/api/api_keywords.robot

*** Variables ***
${BROWSER}        chrome
${UI_URL}         http://localhost:8000  # Replace with actual UI URL
${API_URL}        http://localhost:5000  # Replace with actual API URL
${TEST_USER}      testuser
${TEST_EMAIL}     test@example.com
${TEST_PASSWORD}  Test@123
${TEST_PRODUCT}   Smartphone X

*** Test Cases ***
User Registration And Login
    [Documentation]    Test user registration and login functionality
    [Tags]    smoke    api
    Create API Session    ecommerce    ${API_URL}
    ${response}=    Create Test User    ecommerce    ${TEST_USER}    ${TEST_EMAIL}    ${TEST_PASSWORD}
    Verify Response Status    ${response}    201
    ${token}=    Login User    ecommerce    ${TEST_USER}    ${TEST_PASSWORD}
    Should Not Be Empty    ${token}

Search And Add Product To Cart
    [Documentation]    Test product search and cart functionality
    [Tags]    smoke    ui
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${TEST_USER}    ${TEST_PASSWORD}
    Search For Product    ${TEST_PRODUCT}
    Add Product To Cart    ${TEST_PRODUCT}
    Verify Cart Contains Product    ${TEST_PRODUCT}
    [Teardown]    Close Browser

Complete Purchase Flow
    [Documentation]    Test complete purchase flow from cart to order confirmation
    [Tags]    regression    ui
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${TEST_USER}    ${TEST_PASSWORD}
    Search For Product    ${TEST_PRODUCT}
    Add Product To Cart    ${TEST_PRODUCT}
    Checkout Process    123 Main St, City, Country    Credit Card
    Verify Order Confirmation    Order placed successfully
    [Teardown]    Close Browser

API Cart Operations
    [Documentation]    Test cart operations through API
    [Tags]    api    regression
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${TEST_USER}    ${TEST_PASSWORD}
    ${response}=    Add Product To Cart API    ecommerce    ${token}    product123    2
    Verify Response Status    ${response}    201
    ${cart_response}=    Get Cart Contents    ecommerce    ${token}
    Verify Response Contains    ${cart_response}    product123

Product Search API
    [Documentation]    Test product search through API
    [Tags]    api
    Create API Session    ecommerce    ${API_URL}
    ${response}=    Get From API    ecommerce    /api/products/search?q=${TEST_PRODUCT}
    Verify Response Status    ${response}    200
    ${expected_schema}=    Create Dictionary
    ...    products=@{EMPTY}
    ...    total=0
    Verify Response Schema    ${response}    ${expected_schema}

User Profile Update
    [Documentation]    Test user profile update functionality
    [Tags]    api    regression
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${TEST_USER}    ${TEST_PASSWORD}
    ${update_data}=    Create Dictionary
    ...    name=Updated Name
    ...    phone=1234567890
    ${response}=    Put To API    ecommerce    /api/users/profile    ${update_data}    headers=${token}
    Verify Response Status    ${response}    200
    Verify Response Contains    ${response}    Updated Name

# Add your test cases here 