*** Settings ***
Documentation    Keywords for API tests
Library          RequestsLibrary
Library          Collections
Library          String

*** Variables ***
${TIMEOUT}        10s

*** Keywords ***
Create API Session
    [Arguments]    ${alias}    ${url}
    Create Session    ${alias}    ${url}    verify=True

Get From API
    [Arguments]    ${alias}    ${path}    ${expected_status}=200
    ${response}=    GET On Session    ${alias}    ${path}    expected_status=${expected_status}
    [Return]    ${response}

Post To API
    [Arguments]    ${alias}    ${path}    ${data}    ${expected_status}=201
    ${response}=    POST On Session    ${alias}    ${path}    json=${data}    expected_status=${expected_status}
    [Return]    ${response}

Put To API
    [Arguments]    ${alias}    ${path}    ${data}    ${expected_status}=200
    ${response}=    PUT On Session    ${alias}    ${path}    json=${data}    expected_status=${expected_status}
    [Return]    ${response}

Delete From API
    [Arguments]    ${alias}    ${path}    ${expected_status}=204
    ${response}=    DELETE On Session    ${alias}    ${path}    expected_status=${expected_status}
    [Return]    ${response}

Verify Response Status
    [Arguments]    ${response}    ${expected_status}
    Status Should Be    ${expected_status}    ${response}

Verify Response Contains
    [Arguments]    ${response}    ${expected_text}
    ${body}=    Set Variable    ${response.json()}
    Should Contain    ${body}    ${expected_text}

Verify Response Schema
    [Arguments]    ${response}    ${expected_schema}
    ${body}=    Set Variable    ${response.json()}
    Dictionary Should Contain Sub Dictionary    ${body}    ${expected_schema}

Create Test User
    [Arguments]    ${alias}    ${username}    ${email}    ${password}
    ${user_data}=    Create Dictionary
    ...    username=${username}
    ...    email=${email}
    ...    password=${password}
    ${response}=    Post To API    ${alias}    /api/users    ${user_data}
    [Return]    ${response}

Login User
    [Arguments]    ${alias}    ${username}    ${password}
    ${login_data}=    Create Dictionary
    ...    username=${username}
    ...    password=${password}
    ${response}=    Post To API    ${alias}    /api/auth/login    ${login_data}
    [Return]    ${response.json()['token']}

Add Product To Cart API
    [Arguments]    ${alias}    ${token}    ${product_id}    ${quantity}=1
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${cart_data}=    Create Dictionary
    ...    product_id=${product_id}
    ...    quantity=${quantity}
    ${response}=    Post To API    ${alias}    /api/cart    ${cart_data}    headers=${headers}
    [Return]    ${response}

Get Cart Contents
    [Arguments]    ${alias}    ${token}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    Get From API    ${alias}    /api/cart    headers=${headers}
    [Return]    ${response} 