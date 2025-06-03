*** Settings ***
Documentation    Mobile responsiveness testing scenarios for e-commerce application
Library          SeleniumLibrary
Library          Collections
Resource         ../resources/ui/common/common_keywords.robot
Resource         ../resources/test_data.robot

*** Variables ***
${BROWSER}        chrome
${UI_URL}         http://localhost:8000
${MOBILE_DEVICES}=    ${EMPTY}
...    iPhone SE    320x568
...    iPhone 12 Pro    390x844
...    Pixel 5    393x851
...    Galaxy S20    360x800
...    iPad Mini    768x1024
...    iPad Pro    1024x1366

*** Test Cases ***
Test Mobile Navigation
    [Documentation]    Test mobile navigation menu
    [Tags]    mobile    responsive
    FOR    ${device}    ${resolution}    IN    @{MOBILE_DEVICES}
        Set Mobile Viewport    ${device}    ${resolution}
        Open Browser To E-commerce Site    ${UI_URL}
        Verify Mobile Menu
        [Teardown]    Close Browser
    END

Test Mobile Product Grid
    [Documentation]    Test product grid layout on mobile devices
    [Tags]    mobile    responsive
    FOR    ${device}    ${resolution}    IN    @{MOBILE_DEVICES}
        Set Mobile Viewport    ${device}    ${resolution}
        Open Browser To E-commerce Site    ${UI_URL}
        Verify Product Grid Layout
        [Teardown]    Close Browser
    END

Test Mobile Checkout Flow
    [Documentation]    Test checkout process on mobile devices
    [Tags]    mobile    responsive
    FOR    ${device}    ${resolution}    IN    @{MOBILE_DEVICES}
        Set Mobile Viewport    ${device}    ${resolution}
        Open Browser To E-commerce Site    ${UI_URL}
        Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
        Add Product To Cart    ${PRODUCT_NAME}
        Verify Mobile Checkout Process
        [Teardown]    Close Browser
    END

Test Mobile Form Inputs
    [Documentation]    Test form inputs on mobile devices
    [Tags]    mobile    responsive
    FOR    ${device}    ${resolution}    IN    @{MOBILE_DEVICES}
        Set Mobile Viewport    ${device}    ${resolution}
        Open Browser To E-commerce Site    ${UI_URL}
        Click Element    id=login-button
        Verify Mobile Form Inputs
        [Teardown]    Close Browser
    END

Test Mobile Touch Interactions
    [Documentation]    Test touch interactions on mobile devices
    [Tags]    mobile    responsive
    FOR    ${device}    ${resolution}    IN    @{MOBILE_DEVICES}
        Set Mobile Viewport    ${device}    ${resolution}
        Open Browser To E-commerce Site    ${UI_URL}
        Verify Touch Interactions
        [Teardown]    Close Browser
    END

Test Mobile Image Optimization
    [Documentation]    Test image optimization for mobile devices
    [Tags]    mobile    responsive
    FOR    ${device}    ${resolution}    IN    @{MOBILE_DEVICES}
        Set Mobile Viewport    ${device}    ${resolution}
        Open Browser To E-commerce Site    ${UI_URL}
        Verify Mobile Images
        [Teardown]    Close Browser
    END

*** Keywords ***
Set Mobile Viewport
    [Arguments]    ${device}    ${resolution}
    ${width}    ${height}=    Split String    ${resolution}    x
    Set Window Size    ${width}    ${height}
    Set Selenium Implicit Wait    5s

Verify Mobile Menu
    Click Element    id=mobile-menu-button
    Element Should Be Visible    id=mobile-menu
    ${menu_items}=    Get WebElements    class=mobile-menu-item
    Length Should Be    ${menu_items}    5
    Click Element    id=mobile-menu-close
    Element Should Not Be Visible    id=mobile-menu

Verify Product Grid Layout
    ${products}=    Get WebElements    class=product-item
    FOR    ${product}    IN    @{products}
        ${width}=    Get Element Size    ${product}    width
        ${height}=    Get Element Size    ${product}    height
        Should Be True    ${width} <= 400    Product width exceeds mobile viewport
        Should Be True    ${height} <= 600    Product height exceeds mobile viewport
    END

Verify Mobile Checkout Process
    Click Element    id=cart-icon
    Element Should Be Visible    id=mobile-cart-summary
    Click Element    id=checkout-button
    Element Should Be Visible    id=mobile-checkout-form
    ${form_elements}=    Get WebElements    class=mobile-form-input
    FOR    ${element}    IN    @{form_elements}
        ${is_visible}=    Call Method    ${element}    is_displayed
        Should Be True    ${is_visible}    Form element not visible on mobile
    END

Verify Mobile Form Inputs
    ${inputs}=    Get WebElements    class=form-input
    FOR    ${input}    IN    @{inputs}
        ${type}=    Get Element Attribute    ${input}    type
        ${placeholder}=    Get Element Attribute    ${input}    placeholder
        Should Not Be Empty    ${placeholder}    Input missing placeholder
        IF    '${type}' == 'text' or '${type}' == 'email' or '${type}' == 'password'
            ${autocomplete}=    Get Element Attribute    ${input}    autocomplete
            Should Not Be Empty    ${autocomplete}    Input missing autocomplete attribute
        END
    END

Verify Touch Interactions
    # Test swipe on product carousel
    ${carousel}=    Get WebElement    id=product-carousel
    Swipe    ${carousel}    100    0
    # Test pinch zoom on product images
    ${image}=    Get WebElement    class=product-image
    Pinch    ${image}    2.0
    # Test tap on buttons
    ${buttons}=    Get WebElements    class=mobile-button
    FOR    ${button}    IN    @{buttons}
        Click Element    ${button}
        Sleep    0.5s
    END

Verify Mobile Images
    ${images}=    Get WebElements    tag=img
    FOR    ${image}    IN    @{images}
        ${src}=    Get Element Attribute    ${image}    src
        ${loading}=    Get Element Attribute    ${image}    loading
        Should Be Equal    ${loading}    lazy    Image missing lazy loading
        ${srcset}=    Get Element Attribute    ${image}    srcset
        Should Not Be Empty    ${srcset}    Image missing srcset for responsive loading
    END 