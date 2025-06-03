# E-commerce End-to-End Test Suite

This project contains a comprehensive end-to-end test suite for a hypothetical e-commerce application, built using Robot Framework. It includes tests for both web UI and REST APIs.

## Getting Started

1.  **Clone the repository:**
    ```bash
    git clone <repository_url>
    cd robotframework-ecommerce-suite
    ```

2.  **Install dependencies:**
    ```bash
    pip install -r requirements.txt
    ```

3.  **Run tests:**
    ```bash
    robot tests/
    ```

## Project Structure

```
.
├── README.md
├── requirements.txt
├── tests/
│   ├── api/
│   └── ui/
└── resources/
    ├── api/
    └── ui/
        └── common/
```

## Libraries Used

*   [Robot Framework](https://robotframework.org/)
*   [SeleniumLibrary](https://robotframework.org/SeleniumLibrary/)
*   [RequestsLibrary](https://marketsquare.github.io/robotframework-requests/RequestsLibrary.html)
