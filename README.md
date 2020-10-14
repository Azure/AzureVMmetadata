# AzureVMmetadata <img src="man/figures/logo.png" align="right" width=150 />

[![CRAN](https://www.r-pkg.org/badges/version/AzureVMmetadata)](https://cran.r-project.org/package=AzureVMmetadata)
![Downloads](https://cranlogs.r-pkg.org/badges/AzureVMmetadata)
![R-CMD-check](https://github.com/Azure/AzureKeyVault/workflows/R-CMD-check/badge.svg)

A simple package to access the [instance metadata service](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/instance-metadata-service) in an Azure virtual machine.

The primary repo for this package is at https://github.com/Azure/AzureVMmetadata; please submit issues and PRs there. It is also mirrored at the Cloudyr org at https://github.com/cloudyr/AzureVMmetadata. You can install the development version of the package from GitHub:

```r
devtools::install_github("Azure/AzureVMmetadata")
```

## Accessing metadata

AzureVMmetadata exposes three environments that contain the metadata for the VM:

- `instance`: The instance metadata, containing 2 components: `compute` and `network`
- `attested`: The attested metadata, containing the base64-encoded PKCS-7 certificate for the VM
- `events`: The scheduled events for the VM

The first two are automatically populated when the package is loaded; you can also manually update them with the `update_instance_metadata()` and `update_attested_metadata()` functions. `events` is not populated at package startup (it causes the event scheduler service to be started on the VM, which can take up to several minutes), but you can update it manually with `update_scheduled_events()`.

```r
## these will only be meaningful when run in an Azure VM

# all compute metadata
AzureVMmetadata::instance$compute

# VM name and ID
AzureVMmetadata::instance$compute$name
AzureVMmetadata::instance$compute$vmId

# VM resource details: subscription, resource group, ID
AzureVMmetadata::instance$compute$subscriptionId
AzureVMmetadata::instance$compute$resourceGroupName
AzureVMmetadata::instance$compute$resourceId

# all network metadata
AzureVMmetadata::instance$network

# IPv4 address details (1st network interface)
AzureVMmetadata::instance$network$interface[[1]]$ipv4

# raw PKCS-7 certificate for the VM
AzureVMmetadata::attested$signature

# certificate as an openssl::cert object
AzureVMmetadata::get_vm_cert()
```

----
<p align="center"><a href="https://github.com/Azure/AzureR"><img src="https://github.com/Azure/AzureR/raw/master/images/logo2.png" width=800 /></a></p>
