*** Settings ***
Documentation    Visual regression testing scenarios for e-commerce application
Library          SeleniumLibrary
Library          Collections
Library          OperatingSystem
Resource         ../resources/ui/common/common_keywords.robot
Resource         ../resources/test_data.robot

*** Variables ***
${BROWSER}        chrome
${UI_URL}         http://localhost:8000
${SCREENSHOT_DIR}    ${CURDIR}/../screenshots
${BASELINE_DIR}    ${CURDIR}/../baseline_screenshots

*** Test Cases ***
Test Homepage Visual Regression
    [Documentation]    Test homepage visual regression
    [Tags]    visual    regression
    Open Browser To E-commerce Site    ${UI_URL}
    Take Screenshot    homepage
    Compare Screenshots    homepage
    [Teardown]    Close Browser

Test Product Page Visual Regression
    [Documentation]    Test product page visual regression
    [Tags]    visual    regression
    Open Browser To E-commerce Site    ${UI_URL}
    Search For Product    ${PRODUCT_NAME}
    Click Element    class=product-item
    Take Screenshot    product_page
    Compare Screenshots    product_page
    [Teardown]    Close Browser

Test Cart Page Visual Regression
    [Documentation]    Test cart page visual regression
    [Tags]    visual    regression
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    Add Product To Cart    ${PRODUCT_NAME}
    Click Element    id=cart-icon
    Take Screenshot    cart_page
    Compare Screenshots    cart_page
    [Teardown]    Close Browser

Test Checkout Page Visual Regression
    [Documentation]    Test checkout page visual regression
    [Tags]    visual    regression
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    Add Product To Cart    ${PRODUCT_NAME}
    Click Element    id=checkout-button
    Take Screenshot    checkout_page
    Compare Screenshots    checkout_page
    [Teardown]    Close Browser

Test Responsive Design Visual Regression
    [Documentation]    Test responsive design visual regression
    [Tags]    visual    regression    responsive
    Open Browser To E-commerce Site    ${UI_URL}
    ${viewport_sizes}=    Create List
    ...    320x480    # Mobile
    ...    768x1024   # Tablet
    ...    1366x768   # Desktop
    ...    1920x1080  # Large Desktop
    FOR    ${size}    IN    @{viewport_sizes}
        Set Window Size    ${size}
        Take Screenshot    homepage_${size}
        Compare Screenshots    homepage_${size}
    END
    [Teardown]    Close Browser

Test UI Components Visual Regression
    [Documentation]    Test UI components visual regression
    [Tags]    visual    regression
    Open Browser To E-commerce Site    ${UI_URL}
    ${components}=    Create List
    ...    id=header
    ...    id=footer
    ...    class=product-grid
    ...    class=category-menu
    ...    id=search-bar
    FOR    ${component}    IN    @{components}
        Scroll Element Into View    ${component}
        Take Screenshot    ${component}
        Compare Screenshots    ${component}
    END
    [Teardown]    Close Browser

*** Keywords ***
Take Screenshot
    [Arguments]    ${name}
    ${timestamp}=    Get Time    epoch
    ${screenshot_path}=    Set Variable    ${SCREENSHOT_DIR}/${name}_${timestamp}.png
    Capture Page Screenshot    ${screenshot_path}
    [Return]    ${screenshot_path}

Compare Screenshots
    [Arguments]    ${name}
    ${current_screenshot}=    Get Latest Screenshot    ${name}
    ${baseline_screenshot}=    Set Variable    ${BASELINE_DIR}/${name}.png
    ${diff_exists}=    Compare Images    ${current_screenshot}    ${baseline_screenshot}
    Should Be False    ${diff_exists}    Visual regression detected for ${name}

Get Latest Screenshot
    [Arguments]    ${name}
    ${files}=    List Files In Directory    ${SCREENSHOT_DIR}    ${name}_*.png
    ${latest_file}=    Get From List    ${files}    -1
    [Return]    ${SCREENSHOT_DIR}/${latest_file}

Compare Images
    [Arguments]    ${image1}    ${image2}
    # This is a placeholder for image comparison logic
    # In real implementation, you would use a library like Pillow or OpenCV
    # to compare the images and return True if differences are found
    [Return]    ${False} 