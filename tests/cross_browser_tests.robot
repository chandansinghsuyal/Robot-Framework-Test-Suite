*** Settings ***
Documentation    Cross-browser testing scenarios for e-commerce application
Library          SeleniumLibrary
Library          Collections
Resource         ../resources/ui/common/common_keywords.robot
Resource         ../resources/test_data.robot

*** Variables ***
${UI_URL}         http://localhost:8000
${BROWSERS}    ${EMPTY}
...    chrome
...    firefox
...    safari
...    edge

*** Test Cases ***
Test Login Across Browsers
    [Documentation]    Test login functionality across different browsers
    [Template]    Test Login In Browser
    [Tags]    cross-browser    smoke
    ${BROWSERS}

Test Product Search Across Browsers
    [Documentation]    Test product search across different browsers
    [Template]    Test Search In Browser
    [Tags]    cross-browser    regression
    ${BROWSERS}

Test Checkout Process Across Browsers
    [Documentation]    Test checkout process across different browsers
    [Template]    Test Checkout In Browser
    [Tags]    cross-browser    regression
    ${BROWSERS}

Test Responsive Design
    [Documentation]    Test responsive design across different browsers
    [Template]    Test Responsive Design In Browser
    [Tags]    cross-browser    ui
    ${BROWSERS}

*** Keywords ***
Test Login In Browser
    [Arguments]    ${browser}
    Open Browser    ${UI_URL}    ${browser}
    Maximize Browser Window
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    Element Should Be Visible    id=user-profile
    [Teardown]    Close Browser

Test Search In Browser
    [Arguments]    ${browser}
    Open Browser    ${UI_URL}    ${browser}
    Maximize Browser Window
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    Search For Product    Smartphone X
    Wait Until Element Is Visible    class=product-grid    ${TIMEOUT}
    ${product_count}=    Get Element Count    class=product-item
    Should Be True    ${product_count} > 0
    [Teardown]    Close Browser

Test Checkout In Browser
    [Arguments]    ${browser}
    Open Browser    ${UI_URL}    ${browser}
    Maximize Browser Window
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    Search For Product    Smartphone X
    Add Product To Cart    Smartphone X
    Checkout Process    ${SHIPPING_ADDRESSES}[0]    ${PAYMENT_METHODS}[0]
    Verify Order Confirmation    ${MESSAGES}[0]
    [Teardown]    Close Browser

Test Responsive Design In Browser
    [Arguments]    ${browser}
    Open Browser    ${UI_URL}    ${browser}
    ${viewport_sizes}=    Create List
    ...    320    480    # Mobile
    ...    768    1024   # Tablet
    ...    1024    768   # Desktop
    ...    1920    1080  # Large Desktop
    FOR    ${width}    ${height}    IN    @{viewport_sizes}
        Set Window Size    ${width}    ${height}
        ${is_mobile}=    Run Keyword And Return Status    Element Should Be Visible    class=mobile-menu
        ${is_desktop}=    Run Keyword And Return Status    Element Should Be Visible    class=desktop-menu
        Run Keyword If    ${width} <= 768    Should Be True    ${is_mobile}
        ...    ELSE    Should Be True    ${is_desktop}
    END
    [Teardown]    Close Browser 