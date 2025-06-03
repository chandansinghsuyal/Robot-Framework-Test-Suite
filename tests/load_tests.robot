*** Settings ***
Documentation    Load testing scenarios for e-commerce application
Library          RequestsLibrary
Library          Collections
Library          String
Library          DateTime
Resource         ../resources/api/api_keywords.robot
Resource         ../resources/test_data.robot

*** Variables ***
${API_URL}        http://localhost:5000
${CONCURRENT_USERS}    100
${DURATION}       300    # 5 minutes
${THINK_TIME}     2      # 2 seconds between requests

*** Test Cases ***
Test Concurrent User Load
    [Documentation]    Test system performance under concurrent user load
    [Tags]    load    performance
    Create API Session    ecommerce    ${API_URL}
    ${start_time}=    Get Current Date
    ${end_time}=    Add Time To Date    ${start_time}    ${DURATION} seconds
    ${success_count}=    Set Variable    ${0}
    ${error_count}=    Set Variable    ${0}
    ${total_response_time}=    Set Variable    ${0}
    
    WHILE    ${True}
        ${current_time}=    Get Current Date
        ${elapsed}=    Subtract Date From Date    ${current_time}    ${start_time}
        Exit For Loop If    ${elapsed} > ${DURATION}
        
        ${response}=    Get From API    ecommerce    /api/products
        ${status_code}=    Set Variable    ${response.status_code}
        ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
        
        IF    ${status_code} == 200
            ${success_count}=    Evaluate    ${success_count} + 1
            ${total_response_time}=    Evaluate    ${total_response_time} + ${response_time}
        ELSE
            ${error_count}=    Evaluate    ${error_count} + 1
        END
        
        Sleep    ${THINK_TIME}
    END
    
    ${total_requests}=    Evaluate    ${success_count} + ${error_count}
    ${avg_response_time}=    Evaluate    ${total_response_time} / ${success_count}
    ${success_rate}=    Evaluate    (${success_count} / ${total_requests}) * 100
    
    Should Be True    ${success_rate} >= 95    Success rate below 95%
    Should Be True    ${avg_response_time} <= 1    Average response time above 1 second

Test Product Search Load
    [Documentation]    Test product search performance under load
    [Tags]    load    performance
    Create API Session    ecommerce    ${API_URL}
    ${search_terms}=    Create List
    ...    laptop
    ...    phone
    ...    tablet
    ...    camera
    ...    headphone
    
    FOR    ${term}    IN    @{search_terms}
        ${start_time}=    Get Current Date
        ${response}=    Get From API    ecommerce    /api/products/search?q=${term}
        ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
        Should Be True    ${response_time} <= 0.5    Search response time too high for term: ${term}
    END

Test Cart Operations Load
    [Documentation]    Test cart operations performance under load
    [Tags]    load    performance
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    
    FOR    ${i}    IN RANGE    10
        ${start_time}=    Get Current Date
        ${response}=    Get From API    ecommerce    /api/cart    headers=${headers}
        ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
        Should Be True    ${response_time} <= 0.3    Cart operation response time too high
        Sleep    ${THINK_TIME}
    END

Test Checkout Process Load
    [Documentation]    Test checkout process performance under load
    [Tags]    load    performance
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    
    FOR    ${i}    IN RANGE    5
        ${start_time}=    Get Current Date
        ${response}=    Post To API    ecommerce    /api/checkout    headers=${headers}
        ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
        Should Be True    ${response_time} <= 2    Checkout process response time too high
        Sleep    ${THINK_TIME}
    END

Test Database Query Performance
    [Documentation]    Test database query performance under load
    [Tags]    load    performance
    Create API Session    ecommerce    ${API_URL}
    ${queries}=    Create List
    ...    /api/products?category=electronics
    ...    /api/products?sort=price&order=desc
    ...    /api/products?limit=50&page=1
    ...    /api/orders?status=completed
    ...    /api/users?role=customer
    
    FOR    ${query}    IN    @{queries}
        ${start_time}=    Get Current Date
        ${response}=    Get From API    ecommerce    ${query}
        ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
        Should Be True    ${response_time} <= 0.5    Database query response time too high for: ${query}
        Sleep    ${THINK_TIME}
    END

*** Keywords ***
Get Current Date
    ${date}=    Get Current Date    result_format=epoch
    [Return]    ${date}

Add Time To Date
    [Arguments]    ${date}    ${time_to_add}
    ${new_date}=    Evaluate    ${date} + ${time_to_add}
    [Return]    ${new_date}

Subtract Date From Date
    [Arguments]    ${date1}    ${date2}
    ${diff}=    Evaluate    ${date1} - ${date2}
    [Return]    ${diff} 