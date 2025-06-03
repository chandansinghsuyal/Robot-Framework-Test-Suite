*** Settings ***
Documentation    Data-driven test cases for e-commerce application
Library          SeleniumLibrary
Library          RequestsLibrary
Library          Collections
Resource         ../resources/ui/common/common_keywords.robot
Resource         ../resources/api/api_keywords.robot
Resource         ../resources/test_data.robot

*** Variables ***
${BROWSER}        chrome
${UI_URL}         http://localhost:8000
${API_URL}        http://localhost:5000

*** Test Cases ***
Test Product Search With Different Categories
    [Documentation]    Test product search functionality with different categories
    [Template]    Search Product By Category
    [Tags]    ui    regression
    ${CATEGORIES}

Test Checkout With Different Payment Methods
    [Documentation]    Test checkout process with different payment methods
    [Template]    Complete Checkout With Payment Method
    [Tags]    ui    regression
    ${PAYMENT_METHODS}

Test API Endpoints Availability
    [Documentation]    Test all API endpoints are accessible
    [Template]    Verify API Endpoint
    [Tags]    api    smoke
    ${API_ENDPOINTS}

Test User Registration With Different Data
    [Documentation]    Test user registration with different user data
    [Template]    Register New User
    [Tags]    api    regression
    user1    user1@example.com    Pass@123
    user2    user2@example.com    Pass@123
    user3    user3@example.com    Pass@123

*** Keywords ***
Search Product By Category
    [Arguments]    ${category}
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    Click Element    xpath=//a[contains(text(), '${category}')]
    Wait Until Element Is Visible    class=product-grid    ${TIMEOUT}
    ${product_count}=    Get Element Count    class=product-item
    Should Be True    ${product_count} > 0
    [Teardown]    Close Browser

Complete Checkout With Payment Method
    [Arguments]    ${payment_method}
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    Search For Product    Smartphone X
    Add Product To Cart    Smartphone X
    Checkout Process    ${SHIPPING_ADDRESSES}[0]    ${payment_method}
    Verify Order Confirmation    ${MESSAGES}[0]
    [Teardown]    Close Browser

Verify API Endpoint
    [Arguments]    ${endpoint}
    Create API Session    ecommerce    ${API_URL}
    ${response}=    Get From API    ecommerce    ${endpoint}
    Verify Response Status    ${response}    200

Register New User
    [Arguments]    ${username}    ${email}    ${password}
    Create API Session    ecommerce    ${API_URL}
    ${response}=    Create Test User    ecommerce    ${username}    ${email}    ${password}
    Verify Response Status    ${response}    201
    Verify Response Contains    ${response}    ${MESSAGES}[2] 