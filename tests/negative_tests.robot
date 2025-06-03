*** Settings ***
Documentation    Negative testing scenarios for e-commerce application
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
Test Invalid Login Credentials
    [Documentation]    Test login with invalid credentials
    [Tags]    negative    ui
    Open Browser To E-commerce Site    ${UI_URL}
    ${invalid_credentials}=    Create List
    ...    invalid_user    wrong_password
    ...    ${EMPTY}    ${EMPTY}
    ...    test@example.com    ${EMPTY}
    ...    ${EMPTY}    Test@123
    FOR    ${username}    ${password}    IN    @{invalid_credentials}
        Input Text    id=username    ${username}
        Input Password    id=password    ${password}
        Click Button    id=submit-login
        Element Should Be Visible    class=error-message
        ${error_text}=    Get Text    class=error-message
        Should Contain    ${error_text}    Invalid credentials
    END
    [Teardown]    Close Browser

Test Invalid Product Search
    [Documentation]    Test search with invalid product names
    [Tags]    negative    ui
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${invalid_searches}=    Create List
    ...    @#$%^&*
    ...    ${EMPTY}
    ...    nonexistentproduct123
    FOR    ${search_term}    IN    @{invalid_searches}
        Input Text    id=search-input    ${search_term}
        Press Keys    id=search-input    ENTER
        Wait Until Element Is Visible    class=no-results    ${TIMEOUT}
        Element Should Be Visible    class=no-results
    END
    [Teardown]    Close Browser

Test Invalid Checkout Data
    [Documentation]    Test checkout with invalid data
    [Tags]    negative    ui
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    Search For Product    Smartphone X
    Add Product To Cart    Smartphone X
    ${invalid_data}=    Create List
    ...    ${EMPTY}    Credit Card
    ...    123 Main St    ${EMPTY}
    ...    ${EMPTY}    ${EMPTY}
    FOR    ${address}    ${payment}    IN    @{invalid_data}
        Click Element    id=checkout-button
        Input Text    id=address    ${address}
        Select From List By Label    id=payment-method    ${payment}
        Click Button    id=place-order
        Element Should Be Visible    class=error-message
    END
    [Teardown]    Close Browser

Test Invalid API Requests
    [Documentation]    Test API with invalid requests
    [Tags]    negative    api
    Create API Session    ecommerce    ${API_URL}
    ${invalid_requests}=    Create List
    ...    /api/products/invalid_id
    ...    /api/users/invalid_email
    ...    /api/cart/invalid_product
    FOR    ${endpoint}    IN    @{invalid_requests}
        ${response}=    Get From API    ecommerce    ${endpoint}    expected_status=404
        Verify Response Status    ${response}    404
    END

Test Invalid Product Quantity
    [Documentation]    Test adding invalid product quantities
    [Tags]    negative    api
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${invalid_quantities}=    Create List
    ...    -1
    ...    0
    ...    999999
    FOR    ${quantity}    IN    @{invalid_quantities}
        ${cart_data}=    Create Dictionary
        ...    product_id=product123
        ...    quantity=${quantity}
        ${response}=    Post To API    ecommerce    /api/cart    ${cart_data}    expected_status=400
        Verify Response Status    ${response}    400
    END

Test Invalid Payment Processing
    [Documentation]    Test payment processing with invalid data
    [Tags]    negative    api
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${invalid_payments}=    Create List
    ...    ${EMPTY}
    ...    invalid_card
    ...    expired_card
    FOR    ${payment_method}    IN    @{invalid_payments}
        ${payment_data}=    Create Dictionary
        ...    method=${payment_method}
        ...    amount=100.00
        ${response}=    Post To API    ecommerce    /api/payments    ${payment_data}    expected_status=400
        Verify Response Status    ${response}    400
    END 