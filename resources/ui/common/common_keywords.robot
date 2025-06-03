*** Settings ***
Documentation    Common keywords for UI tests
Library          SeleniumLibrary
Library          String

*** Variables ***
${TIMEOUT}        10s
${DELAY}          0.5s

*** Keywords ***
Open Browser To E-commerce Site
    [Arguments]    ${url}
    Open Browser    ${url}    ${BROWSER}
    Maximize Browser Window
    Set Selenium Implicit Wait    ${TIMEOUT}

Login To Application
    [Arguments]    ${username}    ${password}
    Click Element    id=login-button
    Input Text    id=username    ${username}
    Input Password    id=password    ${password}
    Click Button    id=submit-login
    Wait Until Element Is Visible    id=user-profile    ${TIMEOUT}

Search For Product
    [Arguments]    ${search_term}
    Input Text    id=search-input    ${search_term}
    Press Keys    id=search-input    ENTER
    Wait Until Element Is Visible    class=product-grid    ${TIMEOUT}

Add Product To Cart
    [Arguments]    ${product_name}
    Click Element    xpath=//div[contains(@class, 'product') and contains(., '${product_name}')]//button[contains(@class, 'add-to-cart')]
    Wait Until Element Is Visible    class=cart-notification    ${TIMEOUT}

Verify Cart Contains Product
    [Arguments]    ${product_name}    ${quantity}=1
    Click Element    id=cart-icon
    Wait Until Element Is Visible    class=cart-items    ${TIMEOUT}
    Element Should Be Visible    xpath=//div[contains(@class, 'cart-item') and contains(., '${product_name}')]
    ${actual_quantity}=    Get Text    xpath=//div[contains(@class, 'cart-item') and contains(., '${product_name}')]//input[@type='number']
    Should Be Equal As Strings    ${actual_quantity}    ${quantity}

Checkout Process
    [Arguments]    ${shipping_address}    ${payment_method}
    Click Element    id=checkout-button
    Wait Until Element Is Visible    id=shipping-form    ${TIMEOUT}
    Input Text    id=address    ${shipping_address}
    Select From List By Label    id=payment-method    ${payment_method}
    Click Button    id=place-order
    Wait Until Element Is Visible    class=order-confirmation    ${TIMEOUT}

Verify Order Confirmation
    [Arguments]    ${expected_message}
    Wait Until Element Is Visible    class=order-confirmation    ${TIMEOUT}
    ${confirmation_text}=    Get Text    class=order-confirmation
    Should Contain    ${confirmation_text}    ${expected_message}

Logout From Application
    Click Element    id=user-profile
    Click Element    id=logout-button
    Wait Until Element Is Visible    id=login-button    ${TIMEOUT} 