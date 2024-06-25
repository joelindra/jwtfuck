# JWT Security Assessment Toolkit

Welcome to the JWT Security Assessment Toolkit repository. This toolkit is a comprehensive collection of bash scripts designed for in-depth assessment and analysis of JSON Web Tokens (JWTs) security.

## Features

- **JWT HMAC BruteForce**
  - Description: Executes a brute force attack to crack HMAC secrets in JWTs.
  - Purpose: Assess the strength of HMAC algorithms used in JWTs.

- **JWT JKU Assessment**
  - Description: Assesses the security of JKU parameters in JWTs.
  - Purpose: Evaluate the risk of external key URL references in JWTs.

- **JWT Spoofing**
  - Description: Performs JWT spoofing attacks to manipulate token data.
  - Purpose: Demonstrate vulnerabilities related to token manipulation.

- **JWT Reveal Kid**
  - Description: Explores vulnerabilities related to revealing the 'kid' parameter in JWTs.
  - Purpose: Highlight risks associated with exposing key identifiers in JWT implementations.

## Target Audience

- **Penetration Testers:** Ideal for security professionals conducting penetration testing and vulnerability assessments, providing advanced tools for JWT security analysis.
- **Security Researchers:** Useful for researchers exploring JWT security vulnerabilities and contributing to the advancement of JWT security best practices.
- **Application Developers:** Offers insights into JWT security risks, aiding developers in implementing robust JWT authentication and validation mechanisms.

## Usage Instructions

1. Clone the repository to your local environment.
   ```sh
   git clone https://github.com/joelindra/jwtfuck.git
   ```
2. Go to the directory
   ```
   cd jwtfuck
   ```
3. Run the script

   ```
   bash main.sh
   ```

Contributions and Feedback
Contributions and feedback are welcome! Please submit issues, feature requests, or pull requests to enhance the functionality and usability of this toolkit.

Disclaimer
This toolkit is intended for educational and security assessment purposes only. Usage on systems without explicit authorization is strictly prohibited. The developers and contributors of this toolkit are not liable for any misuse or unauthorized access resulting from its usage.

