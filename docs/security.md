# Resources that help security
## Route Tables
A route table can restrict which subnets or networks are reachable.

By not defining a route to sensitive resources, you effectively make them unreachable from certain parts of the network (security by absence of a path).

This principle is heavily used in cloud environments (e.g., AWS route tables for VPC subnets).

## Network Security Groups
A network security group (NSG) acts as a stateful firewall at the subnet or network interface level. 

It improves security by explicitly controlling inbound and outbound traffic with allow/deny rules based on IP, port, and protocol. 

This ensures only approved traffic reaches workloads, reducing the attack surface and limiting lateral movement. In effect, it enforces least privilege at the network layer.

## NAT Gateway
A NAT gateway improves security by allowing outbound internet access from private subnets without exposing those resources to unsolicited inbound connections. 

Internal hosts can initiate traffic to the internet, but external hosts cannot initiate connections back, since the NAT translates private IPs into a single public IP. 

This prevents direct exposure of sensitive workloads while still enabling updates, API calls, or other necessary outbound communication.

## User Roles
A user role strengthens security by enforcing role-based access control (RBAC)—users are granted only the permissions necessary to perform their duties, nothing more. 

This limits the damage that could result from compromised credentials or human error, since access is confined to defined tasks. Roles also centralize policy enforcement, making it easier to maintain the principle of least privilege across an organization.

