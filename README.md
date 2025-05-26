# Tokenized Decentralized Structured Products

A comprehensive smart contract system built on Stacks blockchain using Clarity for managing tokenized structured financial products in a decentralized manner.

## Overview

This project implements a complete ecosystem for creating, verifying, tracking, and managing structured financial products on the blockchain. The system ensures investor protection, risk assessment, and regulatory compliance through a series of interconnected smart contracts.

## Architecture

The system consists of five core smart contracts:

### 1. Product Verification Contract (`product-verification.clar`)
- **Purpose**: Validates structured instruments and ensures compliance
- **Key Features**:
    - Product submission and verification workflow
    - Authorized verifier management
    - Verification status tracking
    - Product metadata storage

### 2. Component Tracking Contract (`component-tracking.clar`)
- **Purpose**: Records underlying asset composition and tracks changes
- **Key Features**:
    - Asset component management
    - Weight percentage tracking
    - Price history recording
    - Portfolio value calculation

### 3. Risk Assessment Contract (`risk-assessment.clar`)
- **Purpose**: Evaluates product complexity and risk metrics
- **Key Features**:
    - Multi-factor risk scoring
    - Configurable risk weights
    - Risk level categorization (Low to Extreme)
    - Authorized assessor management

### 4. Performance Monitoring Contract (`performance-monitoring.clar`)
- **Purpose**: Tracks product returns and performance metrics
- **Key Features**:
    - NAV tracking
    - Performance metrics (returns, volatility, Sharpe ratio)
    - Benchmark comparison
    - Historical performance data

### 5. Investor Protection Contract (`investor-protection.clar`)
- **Purpose**: Ensures appropriate risk disclosure and investor suitability
- **Key Features**:
    - Investor profiling and KYC
    - Suitability assessment
    - Risk disclosure management
    - Compliance reporting

## Smart Contract Features

### Security Features
- Role-based access control
- Authorized operator management
- Input validation and error handling
- Immutable audit trails

### Data Management
- Comprehensive product metadata
- Historical tracking capabilities
- Performance analytics
- Risk assessment metrics

### Compliance Features
- Investor suitability checks
- Risk disclosure requirements
- Regulatory reporting capabilities
- Audit trail maintenance

## Getting Started

### Prerequisites
- Stacks blockchain development environment
- Clarity CLI tools
- Node.js and npm for testing

### Installation

1. Clone the repository:
   \`\`\`bash
   git clone <repository-url>
   cd tokenized-structured-products
   \`\`\`

2. Install dependencies:
   \`\`\`bash
   npm install
   \`\`\`

3. Run tests:
   \`\`\`bash
   npm test
   \`\`\`

### Deployment

Deploy contracts to Stacks testnet:
\`\`\`bash
clarinet deploy --testnet
\`\`\`

## Usage Examples

### Creating a Structured Product

1. **Submit Product for Verification**:
   \`\`\`clarity
   (contract-call? .product-verification submit-product
   "Equity-Linked Note"
   (list "BTC" "ETH" "STX")
   u3
   u1000000)
   \`\`\`

2. **Add Components**:
   \`\`\`clarity
   (contract-call? .component-tracking add-component
   u1
   "BTC"
   u50
   u45000)
   \`\`\`

3. **Assess Risk**:
   \`\`\`clarity
   (contract-call? .risk-assessment assess-product-risk
   u1
   u70
   u60
   u80
   u40)
   \`\`\`

### Investor Onboarding

1. **Update Investor Profile**:
   \`\`\`clarity
   (contract-call? .investor-protection update-investor-profile
   'SP1INVESTOR...
   u3
   u80
   u5
   u4)
   \`\`\`

2. **Acknowledge Risk Disclosure**:
   \`\`\`clarity
   (contract-call? .investor-protection acknowledge-risk-disclosure u1)
   \`\`\`

## Risk Management

The system implements a comprehensive risk management framework:

- **Risk Levels**: 1 (Low) to 5 (Extreme)
- **Risk Factors**: Volatility, Liquidity, Complexity, Concentration
- **Suitability Levels**: Conservative, Moderate, Aggressive, Sophisticated
- **Compliance Checks**: Automated suitability verification

## Testing

The project includes comprehensive test suites using Vitest:

\`\`\`bash
npm run test
npm run test:coverage
\`\`\`

## API Reference

### Product Verification
- \`submit-product\`: Submit new product for verification
- \`verify-product\`: Verify submitted product
- \`get-product-status\`: Get verification status

### Component Tracking
- \`add-component\`: Add asset component to product
- \`update-component-price\`: Update component pricing
- \`calculate-portfolio-value\`: Calculate total portfolio value

### Risk Assessment
- \`assess-product-risk\`: Conduct risk assessment
- \`get-risk-assessment\`: Retrieve risk metrics
- \`update-risk-weights\`: Modify risk factor weights

### Performance Monitoring
- \`record-performance\`: Record performance data
- \`get-latest-performance\`: Get current performance
- \`calculate-relative-performance\`: Compare to benchmark

### Investor Protection
- \`update-investor-profile\`: Update investor information
- \`check-investor-suitability\`: Verify investment suitability
- \`acknowledge-risk-disclosure\`: Confirm risk understanding

## Contributing

1. Fork the repository
2. Create a feature branch
3. Implement changes with tests
4. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Disclaimer

This software is for educational and development purposes. It should not be used in production without proper security audits and regulatory compliance review.
