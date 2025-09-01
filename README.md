# Multi-Tenant Architecture

## Overview

This Terraform-based infrastructure project provisions isolated environments for multiple research teams at NASA. Each team receives its own private network and resource group, ensuring strong separation of workloads while maintaining centralized governance. The architecture supports scalability, modularity, and secure access via Microsoft Entra ID.

## Microsoft Entra ID Integration

This project uses Microsoft Entra ID (formerly Azure Active Directory) for secure authentication and access control. The registered application must have appropriate RBAC permissions to provision resources across subscriptions.

- **App Registration**: Required for Terraform to authenticate via service principal.
- **RBAC Setup**: Ensure the app has Contributor or Owner roles on the target subscription.
- **Tenant Isolation**: Each team’s environment is scoped to its own subnet and resource group, with access managed via Entra ID groups.

## Security Considerations

Because the infrastructure supports scientific research data (not health or PII), the following security measures were prioritized:

- **Encryption in Transit**: All traffic between resources is encrypted using Azure defaults.
- **Private by Default**: All subnets and resources are deployed with private IPs and no public exposure.
- **No Encryption at Rest**: Not implemented due to the non-sensitive nature of the data and performance trade-offs.


## Deployment

To deploy the infrastructure, follow these steps:

1. Run the following command: 
    ```cp main.tf.example main.tf```
2. Replace ```subscription_id```, ```client_id```, ```client_secret```, ```tenant_id``` with the values provided in your Azure account.
    - subscription_id - A GUID that uniquely identifies your Azure subscription.
    - client_id - Identifies the app you've registered in Microsoft Entra ID.
    - client_secret - A password-like credential generated for your registered app.
    - tenant_id - A unique identifier for your Microsoft Entra ID (formerly Azure Active Directory) instance.
3. Although ```variables.tf``` can work just fine in a regular environment, here is more information about the fields.
    - environment - baseline (sit, uat, prod)
    - team_locations - map that container information about each team and their locations. For additional teams, you will have to add their information here.
    - team_networks - Custom private address spaces and subnets for each team
    - shared_location - Location of where the shared resource group is stored.
    - backend local path - Location of your statefile for terraform. Set it to ```environments/<your-environment>/terraform.tf```
4. Initialize terraform with the following command:
    ```terraform init```
    ![terraform init 2](docs/images/terraforminit2.png)
5. Plan the deployment to view the resources to be created:
    ```terraform plan```
    ![terraform plan 1](docs/images/terraformplan1.png)
    ![terraform plan 2](docs/images/terraformplan2.png)
6. Apply the deployment if there are no issues.
    ```terraform apply```
    ![terraform apply 3](docs/images/terraformapply3.png)
7. If you would like to view the outputs, you can also run the command
    ```terraform output```
    ![terraform output](docs/images/terraformoutput.png)

## Deletion
1. Make sure to run ```terraform init``` if you haven't already
2. Run the following command to destroy the stack:
    ```terraform destroy```

## Submission Notes

This repository is submitted as part of an interview project. Please refer to the `main.tf.example` and `variables.tf` files for configuration. Screenshots are included in the `docs/images` folder to illustrate key deployment steps.

Feel free to reach out during the interview for a walkthrough of the architecture and design decisions.
