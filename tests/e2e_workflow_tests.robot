*** Settings ***
Documentation    End-to-end workflow testing scenarios for e-commerce application
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
Test Complete Purchase Workflow
    [Documentation]    Test complete purchase workflow from product selection to order confirmation
    [Tags]    e2e    workflow
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    
    # Browse and select product
    Search For Product    ${PRODUCT_NAME}
    ${product_price}=    Get Text    class=product-price
    Click Element    class=product-item
    
    # Add to cart
    Click Element    id=add-to-cart
    ${cart_total}=    Get Text    id=cart-total
    Should Be Equal    ${cart_total}    ${product_price}
    
    # Proceed to checkout
    Click Element    id=checkout-button
    Element Should Be Visible    id=checkout-form
    
    # Fill shipping information
    Input Text    id=shipping-address    ${SHIPPING_ADDRESS}
    Input Text    id=shipping-city    ${SHIPPING_CITY}
    Input Text    id=shipping-zip    ${SHIPPING_ZIP}
    
    # Fill payment information
    Input Text    id=card-number    ${CARD_NUMBER}
    Input Text    id=card-expiry    ${CARD_EXPIRY}
    Input Text    id=card-cvv    ${CARD_CVV}
    
    # Place order
    Click Element    id=place-order
    Element Should Be Visible    id=order-confirmation
    ${order_id}=    Get Text    id=order-number
    Should Not Be Empty    ${order_id}
    
    # Verify order in database
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    Get From API    ecommerce    /api/orders/${order_id}    headers=${headers}
    Should Be Equal As Strings    ${response.json()['status']}    completed
    
    [Teardown]    Close Browser

Test User Registration And First Purchase
    [Documentation]    Test user registration and first purchase workflow
    [Tags]    e2e    workflow
    Open Browser To E-commerce Site    ${UI_URL}
    
    # Register new user
    Click Element    id=register-button
    Input Text    id=username    ${NEW_USER}
    Input Text    id=email    ${NEW_EMAIL}
    Input Text    id=password    ${NEW_PASSWORD}
    Click Element    id=submit-registration
    
    # Verify registration
    Element Should Be Visible    id=registration-success
    
    # Complete first purchase
    Search For Product    ${PRODUCT_NAME}
    Click Element    class=product-item
    Click Element    id=add-to-cart
    Click Element    id=checkout-button
    
    # Fill required information
    Input Text    id=shipping-address    ${SHIPPING_ADDRESS}
    Input Text    id=card-number    ${CARD_NUMBER}
    Click Element    id=place-order
    
    # Verify first purchase
    Element Should Be Visible    id=first-purchase-badge
    
    [Teardown]    Close Browser

Test Product Review Workflow
    [Documentation]    Test product review submission workflow
    [Tags]    e2e    workflow
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    
    # Purchase product
    Search For Product    ${PRODUCT_NAME}
    Click Element    class=product-item
    Click Element    id=add-to-cart
    Click Element    id=checkout-button
    Click Element    id=place-order
    
    # Wait for order completion
    Sleep    5s
    
    # Submit review
    Click Element    id=write-review
    Input Text    id=review-title    ${REVIEW_TITLE}
    Input Text    id=review-content    ${REVIEW_CONTENT}
    Select From List By Value    id=rating    5
    Click Element    id=submit-review
    
    # Verify review submission
    Element Should Be Visible    id=review-success
    ${review_id}=    Get Text    id=review-id
    Should Not Be Empty    ${review_id}
    
    # Verify review in database
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    Get From API    ecommerce    /api/reviews/${review_id}    headers=${headers}
    Should Be Equal As Strings    ${response.json()['title']}    ${REVIEW_TITLE}
    
    [Teardown]    Close Browser

Test Return And Refund Workflow
    [Documentation]    Test product return and refund workflow
    [Tags]    e2e    workflow
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    
    # Purchase product
    Search For Product    ${PRODUCT_NAME}
    Click Element    class=product-item
    Click Element    id=add-to-cart
    Click Element    id=checkout-button
    Click Element    id=place-order
    
    # Wait for order completion
    Sleep    5s
    
    # Initiate return
    Click Element    id=return-item
    Select From List By Value    id=return-reason    damaged
    Input Text    id=return-description    ${RETURN_DESCRIPTION}
    Click Element    id=submit-return
    
    # Verify return request
    Element Should Be Visible    id=return-success
    ${return_id}=    Get Text    id=return-id
    Should Not Be Empty    ${return_id}
    
    # Verify return in database
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    Get From API    ecommerce    /api/returns/${return_id}    headers=${headers}
    Should Be Equal As Strings    ${response.json()['status']}    pending
    
    [Teardown]    Close Browser

Test Customer Support Workflow
    [Documentation]    Test customer support ticket workflow
    [Tags]    e2e    workflow
    Open Browser To E-commerce Site    ${UI_URL}
    Login To Application    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    
    # Create support ticket
    Click Element    id=support-button
    Select From List By Value    id=ticket-category    technical
    Input Text    id=ticket-subject    ${TICKET_SUBJECT}
    Input Text    id=ticket-description    ${TICKET_DESCRIPTION}
    Click Element    id=submit-ticket
    
    # Verify ticket creation
    Element Should Be Visible    id=ticket-success
    ${ticket_id}=    Get Text    id=ticket-id
    Should Not Be Empty    ${ticket_id}
    
    # Verify ticket in database
    Create API Session    ecommerce    ${API_URL}
    ${token}=    Login User    ecommerce    ${CUSTOMER_USER}    ${CUSTOMER_PASSWORD}
    ${headers}=    Create Dictionary    Authorization=Bearer ${token}
    ${response}=    Get From API    ecommerce    /api/tickets/${ticket_id}    headers=${headers}
    Should Be Equal As Strings    ${response.json()['status']}    open
    
    # Add response to ticket
    Input Text    id=ticket-response    ${TICKET_RESPONSE}
    Click Element    id=submit-response
    
    # Verify response
    Element Should Be Visible    id=response-success
    ${response_id}=    Get Text    id=response-id
    Should Not Be Empty    ${response_id}
    
    [Teardown]    Close Browser 