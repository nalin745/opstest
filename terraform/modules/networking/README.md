# Networking Module

This module creates the network foundation for the Rightmo Senior DevOps
Engineer practical assessment.

## Resources

- One VPC
- Public subnets across multiple Availability Zones
- Private application subnets
- Isolated database subnets
- Internet Gateway
- Optional NAT Gateways
- Public and private route tables
- Database subnet group
- Optional VPC Flow Logs

## NAT Gateway Modes

### Cost-optimized mode

```hcl
single_nat_gateway = true

