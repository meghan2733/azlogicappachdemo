# Azure Logic App ACH File Processing Demo

This repository contains Terraform HCL code to provision an Azure Logic App (Consumption Tier) and Azure Blob Storage Container setup for processing and validating ACH (Automated Clearing House) files used in the insurance industry for processing claims, refunds, and premiums.

## Architecture Overview

The solution consists of:

1. **Azure Storage Account** with three blob containers:
   - `ach-input`: For incoming ACH files to be processed
   - `ach-validated`: For successfully validated ACH files
   - `ach-failed`: For files that failed validation

2. **Azure Logic App (Consumption Tier)** that:
   - Polls the `ach-input` container every 3 minutes
   - Validates ACH file format according to NACHA standards
   - Moves validated files to `ach-validated` container
   - Moves invalid files to `ach-failed` container

## ACH File Validation

The Logic App validates ACH files based on NACHA format requirements:

- **File Header Record (Type 1)**: Verifies the file starts with a record type '1'
- **Batch Header Record (Type 5)**: Checks for presence of batch header (in first few records)
- **Entry Detail Records (Type 6)**: Validated as part of record count
- **Batch Control Record (Type 8)**: Checks for presence of batch control
- **File Control Record (Type 9)**: Verifies the file ends with a file control record (before any padding)
- **Minimum Records**: File must contain at least 4 records (file header, batch header, batch control, file control)

### Validation Limitations

The Logic App provides **basic structural validation** using native Logic App expressions. This is suitable for initial file screening but has limitations:

- Does not validate individual record lengths (94 characters each)
- Does not verify field-level data (routing numbers, account numbers, amounts)
- Does not validate hash totals and control counts
- May not handle all edge cases (e.g., files with padding, malformed records)
- Limited error reporting capabilities

### Recommended Enhancements

For production use in the insurance industry processing real ACH files, consider:

1. **Azure Function Integration**: Add an Azure Function with a dedicated ACH parsing library that:
   - Validates each record length (exactly 94 characters)
   - Checks field formats and values (routing numbers, account types, etc.)
   - Verifies batch and file control totals
   - Provides detailed validation error messages
   - Handles edge cases and malformed files

2. **Azure Monitor**: Set up alerts for validation failures and processing errors

3. **Compliance**: Implement audit logging for all file processing activities

4. **Testing**: Thoroughly test with real ACH files from your insurance workflows

**Example Architecture**: Logic App → Azure Function (validation) → Blob Storage (routing)

## Prerequisites

- [Terraform](https://www.terraform.io/downloads.html) >= 1.0
- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and configured
- Azure subscription with appropriate permissions to create:
  - Resource Groups
  - Storage Accounts
  - Logic Apps
  - API Connections

## Authentication

Before deploying, authenticate with Azure:

```bash
az login
az account set --subscription "your-subscription-id"
```

## Deployment

### 1. Clone the Repository

```bash
git clone https://github.com/meghan2733/azlogicappachdemo.git
cd azlogicappachdemo
```

### 2. Configure Variables

Copy the example variables file and customize it:

```bash
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your values:

```hcl
resource_group_name  = "rg-ach-demo"
location             = "eastus"
storage_account_name = "stachfiledemo123"  # Must be globally unique
logic_app_name       = "logic-ach-processor"

tags = {
  Environment = "Demo"
  Purpose     = "ACH File Processing"
  ManagedBy   = "Terraform"
  Owner       = "Your Name"
}
```

**Important**: The `storage_account_name` must be:
- Globally unique across Azure
- 3-24 characters long
- Only lowercase letters and numbers

### 3. Initialize Terraform

```bash
terraform init
```

### 4. Review the Plan

```bash
terraform plan
```

### 5. Apply the Configuration

```bash
terraform apply
```

Type `yes` when prompted to confirm the deployment.

### 6. Configure Logic App Workflow

After the infrastructure is provisioned, you'll need to manually configure the Logic App workflow in the Azure Portal:

1. Navigate to the Logic App in Azure Portal
2. Open the Logic App Designer
3. Configure the Azure Blob Storage connection with your storage account
4. The workflow is pre-configured to:
   - Run every 3 minutes
   - List blobs in the `ach-input` container
   - Validate each ACH file
   - Move files to appropriate containers based on validation results

Alternatively, you can import the workflow definition from `logic-app-workflow.json`.

## Usage

### Upload ACH Files

Upload ACH files to the `ach-input` blob container:

```bash
# Using Azure CLI
az storage blob upload \
  --account-name <storage_account_name> \
  --container-name ach-input \
  --name sample-ach-file.txt \
  --file ./path/to/ach-file.txt
```

### Monitor Processing

1. The Logic App will automatically poll every 3 minutes
2. Check the Logic App run history in Azure Portal
3. Validated files will appear in the `ach-validated` container
4. Failed files will appear in the `ach-failed` container with `_failed` suffix

### View Outputs

After deployment, view the outputs:

```bash
terraform output
```

To view sensitive outputs:

```bash
terraform output -raw storage_account_primary_connection_string
```

## ACH File Format Reference

ACH files follow the NACHA (National Automated Clearing House Association) format:

- **Record Type 1**: File Header Record (94 characters)
- **Record Type 5**: Batch Header Record (94 characters)
- **Record Type 6**: Entry Detail Record (94 characters)
- **Record Type 7**: Addenda Record (optional, 94 characters)
- **Record Type 8**: Batch Control Record (94 characters)
- **Record Type 9**: File Control Record (94 characters)

Each record is exactly 94 characters and ends with a newline character.

For detailed ACH file format specifications, refer to the [NACHA ACH File Overview](https://achdevguide.nacha.org/ach-file-overview).

## Cleanup

To remove all resources created by this Terraform configuration:

```bash
terraform destroy
```

Type `yes` when prompted to confirm the destruction.

## Files

- `main.tf`: Main Terraform configuration with resource definitions
- `variables.tf`: Input variables for the configuration
- `outputs.tf`: Output values after deployment
- `terraform.tfvars.example`: Example variables file
- `logic-app-workflow.json`: Logic App workflow definition
- `.gitignore`: Git ignore patterns for Terraform files
- `README.md`: This file

## Cost Considerations

This solution uses:

- **Azure Logic App (Consumption)**: Pay-per-execution pricing
- **Azure Storage Account**: Standard LRS (Locally Redundant Storage)
- **API Connections**: Included with Logic App

For pricing details, visit:
- [Logic Apps Pricing](https://azure.microsoft.com/en-us/pricing/details/logic-apps/)
- [Storage Pricing](https://azure.microsoft.com/en-us/pricing/details/storage/)

## Security Considerations

- Storage account uses TLS 1.2 minimum
- Blob containers are set to private access
- Storage account access keys are marked as sensitive outputs
- Blob versioning is enabled for data protection
- Consider implementing:
  - Azure Key Vault for secrets management
  - Azure Monitor for logging and alerting
  - Azure Policy for compliance
  - Network restrictions (firewall rules)

## Troubleshooting

### Storage Account Name Already Exists

If you receive an error about the storage account name already existing, change the `storage_account_name` variable to a unique value.

### Logic App Connection Issues

If the Logic App cannot connect to the storage account:
1. Verify the API connection in Azure Portal
2. Re-authenticate the connection if needed
3. Check storage account firewall settings

### Validation Not Working

If files are not being validated correctly:
1. Check Logic App run history for errors
2. Verify ACH file format (94-character records)
3. Ensure files have proper line endings

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is provided as-is for demonstration purposes.

## References

- [NACHA ACH File Overview](https://achdevguide.nacha.org/ach-file-overview)
- [Azure Logic Apps Documentation](https://docs.microsoft.com/en-us/azure/logic-apps/)
- [Azure Storage Documentation](https://docs.microsoft.com/en-us/azure/storage/)
- [Terraform Azure Provider](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
