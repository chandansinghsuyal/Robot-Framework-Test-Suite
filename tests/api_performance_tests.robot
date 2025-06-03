*** Settings ***
Documentation    API performance testing scenarios for e-commerce application
Library          RequestsLibrary
Library          Collections
Library          String
Library          DateTime
Resource         ../resources/api/api_keywords.robot
Resource         ../resources/test_data.robot

*** Variables ***
${API_URL}        http://localhost:5000
${THINK_TIME}     1      # 1 second between requests
${TIMEOUT}        30     # 30 seconds timeout for requests

*** Test Cases ***
Test API Response Time Under Load
    [Documentation]    Test API response times under various load conditions
    [Tags]    api    performance
    Create API Session    ecommerce    ${API_URL}
    ${endpoints}=    Create List
    ...    /api/products
    ...    /api/categories
    ...    /api/users/profile
    ...    /api/orders
    ...    /api/cart
    
    FOR    ${endpoint}    IN    @{endpoints}
        ${response_times}=    Create List
        FOR    ${i}    IN RANGE    10
            ${start_time}=    Get Current Date
            ${response}=    Get From API    ecommerce    ${endpoint}    timeout=${TIMEOUT}
            ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
            Append To List    ${response_times}    ${response_time}
            Sleep    ${THINK_TIME}
        END
        ${avg_time}=    Calculate Average    ${response_times}
        ${p95_time}=    Calculate Percentile    ${response_times}    95
        Should Be True    ${avg_time} <= 0.5    Average response time too high for ${endpoint}
        Should Be True    ${p95_time} <= 1.0    P95 response time too high for ${endpoint}
    END

Test API Concurrent Requests
    [Documentation]    Test API performance with concurrent requests
    [Tags]    api    performance
    Create API Session    ecommerce    ${API_URL}
    ${concurrent_users}=    Set Variable    50
    ${endpoint}=    Set Variable    /api/products
    ${success_count}=    Set Variable    ${0}
    ${error_count}=    Set Variable    ${0}
    ${response_times}=    Create List
    
    FOR    ${i}    IN RANGE    ${concurrent_users}
        ${start_time}=    Get Current Date
        ${response}=    Get From API    ecommerce    ${endpoint}    timeout=${TIMEOUT}
        ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
        Append To List    ${response_times}    ${response_time}
        
        IF    ${response.status_code} == 200
            ${success_count}=    Evaluate    ${success_count} + 1
        ELSE
            ${error_count}=    Evaluate    ${error_count} + 1
        END
    END
    
    ${success_rate}=    Evaluate    (${success_count} / ${concurrent_users}) * 100
    ${avg_time}=    Calculate Average    ${response_times}
    ${p95_time}=    Calculate Percentile    ${response_times}    95
    
    Should Be True    ${success_rate} >= 95    Success rate below 95%
    Should Be True    ${avg_time} <= 0.5    Average response time too high
    Should Be True    ${p95_time} <= 1.0    P95 response time too high

Test API Resource Usage
    [Documentation]    Test API resource usage under load
    [Tags]    api    performance
    Create API Session    ecommerce    ${API_URL}
    ${endpoints}=    Create List
    ...    /api/products?limit=100
    ...    /api/orders?status=all
    ...    /api/users?role=all
    
    FOR    ${endpoint}    IN    @{endpoints}
        ${response}=    Get From API    ecommerce    ${endpoint}    timeout=${TIMEOUT}
        ${response_size}=    Get Length    ${response.content}
        ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
        
        Should Be True    ${response_size} <= 1000000    Response size too large for ${endpoint}
        Should Be True    ${response_time} <= 2.0    Response time too high for ${endpoint}
    END

Test API Caching Performance
    [Documentation]    Test API caching performance
    [Tags]    api    performance
    Create API Session    ecommerce    ${API_URL}
    ${endpoint}=    Set Variable    /api/products
    ${response_times}=    Create List
    
    # First request (cache miss)
    ${response}=    Get From API    ecommerce    ${endpoint}    timeout=${TIMEOUT}
    ${first_time}=    Set Variable    ${response.elapsed.total_seconds()}
    Append To List    ${response_times}    ${first_time}
    
    # Subsequent requests (cache hit)
    FOR    ${i}    IN RANGE    5
        ${response}=    Get From API    ecommerce    ${endpoint}    timeout=${TIMEOUT}
        ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
        Append To List    ${response_times}    ${response_time}
        Sleep    ${THINK_TIME}
    END
    
    ${avg_time}=    Calculate Average    ${response_times}
    Should Be True    ${avg_time} <= 0.3    Average response time too high with caching

Test API Error Recovery
    [Documentation]    Test API error recovery performance
    [Tags]    api    performance
    Create API Session    ecommerce    ${API_URL}
    ${endpoints}=    Create List
    ...    /api/products/invalid
    ...    /api/orders/invalid
    ...    /api/users/invalid
    
    FOR    ${endpoint}    IN    @{endpoints}
        ${start_time}=    Get Current Date
        ${response}=    Get From API    ecommerce    ${endpoint}    expected_status=404    timeout=${TIMEOUT}
        ${response_time}=    Set Variable    ${response.elapsed.total_seconds()}
        Should Be True    ${response_time} <= 0.5    Error response time too high for ${endpoint}
    END

*** Keywords ***
Calculate Average
    [Arguments]    ${numbers}
    ${sum}=    Evaluate    sum(${numbers})
    ${count}=    Get Length    ${numbers}
    ${average}=    Evaluate    ${sum} / ${count}
    [Return]    ${average}

Calculate Percentile
    [Arguments]    ${numbers}    ${percentile}
    ${sorted}=    Sort List    ${numbers}
    ${index}=    Evaluate    int(len(${sorted}) * ${percentile} / 100)
    ${value}=    Set Variable    ${sorted}[${index}]
    [Return]    ${value} 