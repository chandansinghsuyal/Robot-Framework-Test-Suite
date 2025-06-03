*** Settings ***
Documentation    Security testing scenarios for e-commerce application
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
${INVALID_TOKENS}    ${EMPTY}
...    invalid_token_123
...    expired_token_456
...    malformed_token_789
...    ${EMPTY}

*** Test Cases ***
Test SQL Injection Prevention
    [Documentation]    Test prevention of SQL injection attacks
    [Tags]    security    api
    Create API Session    ecommerce    ${API_URL}
    ${sql_injection_payloads}=    Create List
    ...    ' OR '1'='1
    ...    '; DROP TABLE users; --
    ...    ' UNION SELECT * FROM users; --
    FOR    ${payload}    IN    @{sql_injection_payloads}
        ${response}=    Get From API    ecommerce    /api/products/search?q=${payload}    expected_status=400
        Verify Response Status    ${response}    400
    END

Test XSS Prevention
    [Documentation]    Test prevention of XSS attacks
    [Tags]    security    ui
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${xss_payloads}=    Create List
    ...    <script>alert('XSS')</script>
    ...    <img src=x onerror=alert('XSS')>
    ...    javascript:alert('XSS')
    FOR    ${payload}    IN    @{xss_payloads}
        Input Text    id=search-input    ${payload}
        Press Keys    id=search-input    ENTER
        ${page_source}=    Get Source
        Should Not Contain    ${page_source}    ${payload}
    END
    [Teardown]    Close Browser

Test Authentication Bypass
    [Documentation]    Test prevention of authentication bypass attempts
    [Tags]    security    api
    Create API Session    ecommerce    ${API_URL}
    FOR    ${token}    IN    @{INVALID_TOKENS}
        ${headers}=    Create Dictionary    Authorization=Bearer ${token}
        ${response}=    Get From API    ecommerce    /api/users/profile    headers=${headers}    expected_status=401
        Verify Response Status    ${response}    401
    END

Test Password Policy
    [Documentation]    Test password policy enforcement
    [Tags]    security    api
    Create API Session    ecommerce    ${API_URL}
    ${weak_passwords}=    Create List
    ...    password
    ...    123456
    ...    abcdef
    FOR    ${password}    IN    @{weak_passwords}
        ${user_data}=    Create Dictionary
        ...    username=testuser
        ...    email=test@example.com
        ...    password=${password}
        ${response}=    Post To API    ecommerce    /api/users    ${user_data}    expected_status=400
        Verify Response Status    ${response}    400
    END

Test Rate Limiting
    [Documentation]    Test API rate limiting
    [Tags]    security    api
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    FOR    ${i}    IN RANGE    100
        ${response}=    Get From API    ecommerce    /api/products    headers=${headers}
        ${status}=    Set Variable    ${response.status_code}
        Run Keyword If    ${status} == 429    Exit For Loop
    END
    Should Be Equal As Strings    ${status}    429    Rate limiting not enforced

Test Secure Headers
    [Documentation]    Test presence of security headers
    [Tags]    security    api
    Create API Session    ecommerce    ${API_URL}
    ${response}=    Get From API    ecommerce    /api/products
    ${headers}=    Set Variable    ${response.headers}
    Dictionary Should Contain Key    ${headers}    X-Content-Type-Options
    Dictionary Should Contain Key    ${headers}    X-Frame-Options
    Dictionary Should Contain Key    ${headers}    X-XSS-Protection
    Dictionary Should Contain Key    ${headers}    Strict-Transport-Security 