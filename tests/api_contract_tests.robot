*** Settings ***
Documentation    API contract testing scenarios for e-commerce application
Library          RequestsLibrary
Library          Collections
Library          String
Resource         ../resources/api/api_keywords.robot
Resource         ../resources/test_data.robot

*** Variables ***
${API_URL}        http://localhost:5000

*** Test Cases ***
Test Products API Contract
    [Documentation]    Test products API contract
    [Tags]    api    contract
    Create API Session    ecommerce    ${API_URL}
    ${response}=    Get From API    ecommerce    /api/products
    ${schema}=    Create Dictionary
    ...    products=@{EMPTY}
    ...    total=0
    ...    page=0
    ...    limit=0
    Verify Response Schema    ${response}    ${schema}
    ${products}=    Set Variable    ${response.json()['products']}
    FOR    ${product}    IN    @{products}
        ${product_schema}=    Create Dictionary
        ...    id=${EMPTY}
        ...    name=${EMPTY}
        ...    price=${EMPTY}
        ...    category=${EMPTY}
        ...    description=${EMPTY}
        ...    stock=${EMPTY}
        Dictionary Should Contain Sub Dictionary    ${product}    ${product_schema}
    END

Test User API Contract
    [Documentation]    Test user API contract
    [Tags]    api    contract
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    Get From API    ecommerce    /api/users/profile    headers=${headers}
    ${user_schema}=    Create Dictionary
    ...    id=${EMPTY}
    ...    username=${EMPTY}
    ...    email=${EMPTY}
    ...    name=${EMPTY}
    ...    address=${EMPTY}
    ...    phone=${EMPTY}
    Verify Response Schema    ${response}    ${user_schema}

Test Order API Contract
    [Documentation]    Test order API contract
    [Tags]    api    contract
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    Get From API    ecommerce    /api/orders    headers=${headers}
    ${order_schema}=    Create Dictionary
    ...    orders=@{EMPTY}
    ...    total=0
    Verify Response Schema    ${response}    ${order_schema}
    ${orders}=    Set Variable    ${response.json()['orders']}
    FOR    ${order}    IN    @{orders}
        ${order_item_schema}=    Create Dictionary
        ...    id=${EMPTY}
        ...    date=${EMPTY}
        ...    status=${EMPTY}
        ...    total=${EMPTY}
        ...    items=@{EMPTY}
        Dictionary Should Contain Sub Dictionary    ${order}    ${order_item_schema}
    END

Test Cart API Contract
    [Documentation]    Test cart API contract
    [Tags]    api    contract
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    Get From API    ecommerce    /api/cart    headers=${headers}
    ${cart_schema}=    Create Dictionary
    ...    items=@{EMPTY}
    ...    total=${EMPTY}
    ...    item_count=${EMPTY}
    Verify Response Schema    ${response}    ${cart_schema}
    ${items}=    Set Variable    ${response.json()['items']}
    FOR    ${item}    IN    @{items}
        ${cart_item_schema}=    Create Dictionary
        ...    product_id=${EMPTY}
        ...    name=${EMPTY}
        ...    quantity=${EMPTY}
        ...    price=${EMPTY}
        ...    total=${EMPTY}
        Dictionary Should Contain Sub Dictionary    ${item}    ${cart_item_schema}
    END

Test Error Response Contract
    [Documentation]    Test error response contract
    [Tags]    api    contract
    Create API Session    ecommerce    ${API_URL}
    ${error_schema}=    Create Dictionary
    ...    error=${EMPTY}
    ...    message=${EMPTY}
    ...    code=${EMPTY}
    # Test 404 error
    ${response}=    Get From API    ecommerce    /api/invalid-endpoint    expected_status=404
    Verify Response Schema    ${response}    ${error_schema}
    # Test 400 error
    ${response}=    Get From API    ecommerce    /api/products/invalid-id    expected_status=400
    Verify Response Schema    ${response}    ${error_schema}
    # Test 401 error
    ${response}=    Get From API    ecommerce    /api/users/profile    expected_status=401
    Verify Response Schema    ${response}    ${error_schema}

Test API Versioning
    [Documentation]    Test API versioning contract
    [Tags]    api    contract
    Create API Session    ecommerce    ${API_URL}
    ${versions}=    Create List    v1    v2
    FOR    ${version}    IN    @{versions}
        ${response}=    Get From API    ecommerce    /${version}/products
        ${headers}=    Set Variable    ${response.headers}
        Dictionary Should Contain Key    ${headers}    X-API-Version
        ${api_version}=    Set Variable    ${headers['X-API-Version']}
        Should Be Equal    ${api_version}    ${version}
    END 