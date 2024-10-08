# UML CCDC 2025
Contributions should be organized as follows:

1. Incident and Inject responses should be stored in their associated folder in [0-Documentation/Injects-Incidents/](./0-Documentation/Injects-Incidents/).
2. Printed materials should be stored in [0-Documentation/](./0-Documentation/Printables/).
3. Platform and service related materials should be stored in their respective folder. For example AWS should have it's related materials stored in [Platform-AWS/](./Platform-AWS/).
   * A copy of all scripts should be stored in a folder named after the topic they are associated with in the `Platform/0-Scripts` for example AWS CLI scripts would have a copy stored in [Platform-AWS/0-CLI/](./Platform-AWS/0-CLI/) directory. This is done for quick and easy access.
   * The original script should be located in a folder named after that topic in the `Platform/\<TOPIC\>/0-SCRIPT` folder, this is so it can easily be associated with a README when needed. For example a AWS CLI script on MFA would be located in [Platform-AWS/MFA/0-CLI](./Platform-AWS/MFA/0-CLI/).
   * Documentation should be located in a `Platform/\<TOPIC\>` folder, for example [Platform-AWS/MFA/](./Platform-AWS/MFA/) would be where we place documentation for MFA on AWS.

