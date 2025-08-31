# Decisions
Configuration Management
 1. The deployment scripts are going to be run regularly (daily)
 2. None of the resources are going to be destroyed except under special circumstances (which is why prevent_destroy is not set on any of the resources)
 3. New teams may get added in the future
 4. SIT, UAT, and Production could be all located in the same Azure account

Design Decisions
 1. NAT Gateways have to be separate for all teams
 2. All teams will have the same IAM roles (Operator, Developer, Read-Only)
 3. Key Vault makes sense as part of the shared resources

Future Developments to make scripts production ready
 1. Create module for users and role assignments
 2. Fix bug where NAT gateway isn't being assigned properly to subnet
 3. Set prevent_destroy flag on the majority of resources
 4. Set backend to store statefiles in Azure instead of local
 5. Configure the routes for the routing table

Appendix: How AI was Used
Appendix: Challenges

## Configuration Management
###  1. The deployment scripts are going to be run regularly (daily)
Shared resources are allowed by querying all users in the system and applying them to the shared resource group. If new users are added, there may be a slight delay until the deployment scripts are kicked off again.

### 2. None of the resources are going to be destroyed except under special circumstances (which is why prevent_destroy is not set on any of the resources)
Network resources are more critical to user workflow than regular application resources. In a true production environment, I would have set prevent_destroy to true on all resources. However, for the sake of this exercise, this was left out to make testing more convenient.

###  3. New teams may get added in the future
For ease of use, variables.tf is where new teams will get added. There are two variables ```team_networks``` and ```team_locations``` where custom information about the teams can get specified.

### 4. SIT, UAT, and Production could be all located in the same Azure account
While, this is not a setup I recommend, I assumed that it is possible to set up all three baselines in the same account if needed.

## Design Decisions
### 1. NAT Gateways have to be separate for all teams
Each team has their own dedicated NAT gateway just in case there is separate billing for high traffic for one team and ease of debugging.

### 2. All teams will have the same IAM roles (Operator, Developer, Read-Only)
New roles can be added, but this will require a DevOps engineer to add the custom roles to the terraform script, and once added, the new role would be available to all teams, not just the individual team that requested it.

### 3. Key Vault makes sense as part of the shared resources
When it comes to certain data like recommended Azure VM image URNs that have gone through proper security approvals, it makes sense to have this as part of the shared storage, so when developers make new deployments, they won't have to "fish" for the latest recommended images and won't deploy outdated versions of docker. 

## Future Developments
### 1. Create module for users and role assignments
Would be able to restore users if Azure account somehow gets deleted.

### 2. Fix bug where NAT gateway isn't being assigned properly to subnet
Although this was part of the design, had an odd issue where NAT gateway was not assigned to the subnet, and had to be manually attached after deployment is complete.

### 3. Set prevent_destroy flag on the majority or all resources
Once these resources are created, it's safest to prevent resources from being destroyed to prevent risks for tenants.

### 4. Set backend to store statefiles in Azure instead of local
Having statefiles in Azure allows there to be multiple collaborators on the same terraform.

### 5. Only a basic routing table was created for now.
I didn't have time to configure everything for the routing table, but if I had time, I would have configured more rules.

## Appendix: How AI was used
I have no experience with Azure, and I used AI to catch up on Azure terminology, especially in reference to AWS. I found that ChatGPT had limited information about Azure, but Copilot had better documentation as a Microsoft product.

I used AI to double check on terraform code that may have been missing or can cause issues.

I used Copilot as a sounding board during the architecture design process to decide what resources were the best to add, and which configuration may be easier to maintain longer term.

## Appendix: Challenges
1. A lot of permissions are involved when it comes to allowing permissions to provision a virtual machine, so custom roles ended up taking more time than expected.
2. Azure CLI is more effective than Azure UI when provisioning certain resources such as role assignments. The UI was challenging to navigate.


