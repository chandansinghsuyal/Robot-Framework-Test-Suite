*** Variables ***
# User Data
${ADMIN_USER}        admin
${ADMIN_PASSWORD}    Admin@123
${CUSTOMER_USER}     customer
${CUSTOMER_PASSWORD} Customer@123

# Product Data
${PRODUCTS}    ${EMPTY}
...    Smartphone X    999.99    Electronics
...    Laptop Pro      1499.99   Electronics
...    Wireless Earbuds    79.99    Accessories
...    Smart Watch     199.99    Accessories
...    Gaming Console  499.99    Electronics

# Payment Methods
${PAYMENT_METHODS}    ${EMPTY}
...    Credit Card
...    PayPal
...    Apple Pay
...    Google Pay

# Shipping Addresses
${SHIPPING_ADDRESSES}    ${EMPTY}
...    123 Main St, City, Country
...    456 Park Ave, Town, Country
...    789 Ocean Dr, Beach, Country

# Test Categories
${CATEGORIES}    ${EMPTY}
...    Electronics
...    Accessories
...    Clothing
...    Books
...    Home & Garden

# API Endpoints
${API_ENDPOINTS}    ${EMPTY}
...    /api/products
...    /api/categories
...    /api/users
...    /api/orders
...    /api/cart

# Expected Messages
${MESSAGES}    ${EMPTY}
...    Order placed successfully
...    Product added to cart
...    User registered successfully
...    Profile updated successfully
...    Payment processed successfully 