*** Settings ***
Documentation    Performance and load testing scenarios for e-commerce application
Library          SeleniumLibrary
Library          RequestsLibrary
Library          Collections
Library          DateTime
Resource         ../resources/ui/common/common_keywords.robot
Resource         ../resources/api/api_keywords.robot
Resource         ../resources/test_data.robot

*** Variables ***
${BROWSER}        chrome
${UI_URL}         http://localhost:8000
${API_URL}        http://localhost:5000
${LOAD_TEST_USERS}    10
${CONCURRENT_REQUESTS}    5

*** Test Cases ***
Test Page Load Performance
    [Documentation]    Test the performance of main page loading
    [Tags]    performance    ui
    ${start_time}=    Get Current Date
    Open Browser To E-commerce Site    ${UI_URL}
    ${end_time}=    Get Current Date
    ${duration}=    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${duration} < 3    Page load took more than 3 seconds

Test Search Response Time
    [Documentation]    Test the response time of search functionality
    [Tags]    performance    ui
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${start_time}=    Get Current Date
    Search For Product    Smartphone X
    ${end_time}=    Get Current Date
    ${duration}=    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${duration} < 2    Search took more than 2 seconds
    [Teardown]    Close Browser

Test API Response Time
    [Documentation]    Test the response time of API endpoints
    [Tags]    performance    api
    Create API Session    ecommerce    ${API_URL}
    ${start_time}=    Get Current Date
    ${response}=    Get From API    ecommerce    /api/products
    ${end_time}=    Get Current Date
    ${duration}=    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${duration} < 1    API response took more than 1 second

Test Concurrent User Load
    [Documentation]    Test the application under concurrent user load
    [Tags]    load    api
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${start_time}=    Get Current Date
    FOR    ${i}    IN RANGE    ${CONCURRENT_REQUESTS}
        ${response}=    Get Cart Contents    ecommerce    ${token}
        Verify Response Status    ${response}    200
    END
    ${end_time}=    Get Current Date
    ${duration}=    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${duration} < 5    Concurrent requests took more than 5 seconds

Test Database Performance
    [Documentation]    Test database performance with multiple operations
    [Tags]    performance    api
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${start_time}=    Get Current Date
    FOR    ${i}    IN RANGE    ${LOAD_TEST_USERS}
        ${user_data}=    Create Dictionary
        ...    username=loadtest${i}
        ...    email=loadtest${i}@example.com
        ...    password=Test@123
        ${response}=    Post To API    ecommerce    /api/users    ${user_data}
        Verify Response Status    ${response}    201
    END
    ${end_time}=    Get Current Date
    ${duration}=    Subtract Date From Date    ${end_time}    ${start_time}
    Should Be True    ${duration} < 10    Database operations took more than 10 seconds

*** Keywords ***
Subtract Date From Date
    [Arguments]    ${date1}    ${date2}
    ${diff}=    Subtract Date    ${date1}    ${date2}
    [Return]    ${diff} 