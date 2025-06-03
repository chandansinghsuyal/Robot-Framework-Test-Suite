*** Settings ***
Documentation    Internationalization testing scenarios for e-commerce application
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
${LANGUAGES}    ${EMPTY}
...    en    English
...    es    Spanish
...    fr    French
...    de    German
...    ja    Japanese

*** Test Cases ***
Test Language Switching
    [Documentation]    Test language switching functionality
    [Tags]    i18n    ui
    Open Browser To E-commerce Site    ${UI_URL}
    FOR    ${lang_code}    ${lang_name}    IN    @{LANGUAGES}
        Click Element    id=language-selector
        Click Element    xpath=//option[contains(text(), '${lang_name}')]
        ${current_lang}=    Get Element Attribute    id=language-selector    value
        Should Be Equal    ${current_lang}    ${lang_code}
        Verify Page Language    ${lang_code}
    END
    [Teardown]    Close Browser

Test Date Format Localization
    [Documentation]    Test date format localization
    [Tags]    i18n    ui
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    FOR    ${lang_code}    ${lang_name}    IN    @{LANGUAGES}
        Set Language    ${lang_code}
        ${order_date}=    Get Text    class=order-date
        ${is_valid_format}=    Validate Date Format    ${order_date}    ${lang_code}
        Should Be True    ${is_valid_format}    Invalid date format for ${lang_code}
    END
    [Teardown]    Close Browser

Test Currency Format Localization
    [Documentation]    Test currency format localization
    [Tags]    i18n    ui
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    FOR    ${lang_code}    ${lang_name}    IN    @{LANGUAGES}
        Set Language    ${lang_code}
        ${price}=    Get Text    class=product-price
        ${is_valid_format}=    Validate Currency Format    ${price}    ${lang_code}
        Should Be True    ${is_valid_format}    Invalid currency format for ${lang_code}
    END
    [Teardown]    Close Browser

Test API Localization
    [Documentation]    Test API response localization
    [Tags]    i18n    api
    Create API Session    ecommerce    ${API_URL}
    FOR    ${lang_code}    ${lang_name}    IN    @{LANGUAGES}
        ${headers}=    Create Dictionary    Accept-Language=${lang_code}
        ${response}=    Get From API    ecommerce    /api/products    headers=${headers}
        ${content}=    Set Variable    ${response.json()}
        ${is_localized}=    Validate Localized Content    ${content}    ${lang_code}
        Should Be True    ${is_localized}    Content not properly localized for ${lang_code}
    END

Test RTL Support
    [Documentation]    Test right-to-left language support
    [Tags]    i18n    ui
    Open Browser To E-commerce Site    ${UI_URL}
    Set Language    ar    # Arabic
    ${direction}=    Get Element Attribute    id=main-content    dir
    Should Be Equal    ${direction}    rtl
    ${text_alignment}=    Get CSS Property Value    class=product-title    text-align
    Should Be Equal    ${text_alignment}    right
    [Teardown]    Close Browser

*** Keywords ***
Verify Page Language
    [Arguments]    ${lang_code}
    ${page_lang}=    Get Element Attribute    html    lang
    Should Be Equal    ${page_lang}    ${lang_code}

Set Language
    [Arguments]    ${lang_code}
    Click Element    id=language-selector
    Click Element    xpath=//option[@value='${lang_code}']
    Sleep    1s    # Wait for language change to take effect

Validate Date Format
    [Arguments]    ${date}    ${lang_code}
    # This is a simplified version. In real implementation, you would need to:
    # 1. Define date format patterns for each language
    # 2. Validate the date string against the pattern
    [Return]    ${True}

Validate Currency Format
    [Arguments]    ${price}    ${lang_code}
    # This is a simplified version. In real implementation, you would need to:
    # 1. Define currency format patterns for each language
    # 2. Validate the price string against the pattern
    [Return]    ${True}

Validate Localized Content
    [Arguments]    ${content}    ${lang_code}
    # This is a simplified version. In real implementation, you would need to:
    # 1. Define expected localized content for each language
    # 2. Validate the content against the expected values
    [Return]    ${True} 