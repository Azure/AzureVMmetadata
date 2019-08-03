metadata_host <- httr::parse_url("http://169.254.169.254")
inst_api_version <- "2019-02-01"
att_api_version <- "2018-10-01"
ev_api_version <- "2017-11-01"


#' Metadata for an Azure VM
#'
#' @param nonce For `update_attested_metadata`, an optional string to use as a nonce.
#' @details
#' The `instance`, `attested` and `events` objects are environments containing the instance metadata, attested metadata, and scheduled events respectively for a VM running in Azure. `instance` and `attested` are automatically populated when you load the AzureVMmetadata package, or you can manually populate them yourself with the `update_instance_metadata` and `update_attested_metadata` functions. `events` is not populated at package startup, because calling the scheduled event service can require up to several minutes if it is not running already. You can manually populate it with the `update_scheduled_events` function.
#'
#' If AzureVMmetadata is loaded in an R session that is _not_ running in an Azure VM, all the metadata environments will be empty.
#'
#' @return
#' The updating functions return the contents of their respective environments as lists, invisibly.
#' @seealso
#' [Instance metadata service documentation](https://docs.microsoft.com/en-us/azure/virtual-machines/windows/instance-metadata-service)
#'
#' To obtain OAuth tokens from the metadata service, see [AzureAuth::get_managed_token]
#'
#' @rdname metadata
#' @export
instance <- new.env()

#' @rdname metadata
#' @export
attested <- new.env()

#' @rdname metadata
#' @export
events <- new.env()


#' @rdname metadata
#' @export
update_instance_metadata <- function()
{
    metadata_host$path <- "metadata/instance"
    metadata_host$query <- list(`api-version`=att_api_version)
    res <- try(httr::GET(metadata_host, httr::add_headers(metadata=TRUE)), silent=TRUE)

    if(!inherits(res, "response") || res$status_code > 299)
        return(NULL)

    inst <- httr::content(res)
    for(x in names(inst))
        instance[[x]] <- inst[[x]]
    invisible(inst)
}


#' @rdname metadata
#' @export
update_attested_metadata <- function(nonce=NULL)
{
    metadata_host$path <- "metadata/attested/document"
    metadata_host$query <- list(`api-version`=att_api_version, nonce=nonce)
    res <- try(httr::GET(metadata_host, httr::add_headers(metadata=TRUE)), silent=TRUE)

    if(!inherits(res, "response") || res$status_code > 299)
        return(NULL)

    att <- httr::content(res)
    for(x in names(att))
        attested[[x]] <- att[[x]]
    invisible(att)
}


#' @rdname metadata
#' @export
update_scheduled_events <- function()
{
    metadata_host$path <- "metadata/scheduledevents"
    metadata_host$query <- list(`api-version`=ev_api_version)
    res <- try(httr::GET(metadata_host, httr::add_headers(metadata=TRUE)), silent=TRUE)

    if(!inherits(res, "response") || res$status_code > 299)
        return(NULL)

    ev <- httr::content(res)
    for(x in names(ev))
        events[[x]] <- ev[[x]]
    invisible(ev)
}


#' Check if R is running in an Azure VM
#' @param nonce An optional string to use as a nonce.
#' @details
#' These functions check if R is running in an Azure VM by attempting to contact the instance metadata host. `in_azure_vm` simply returns TRUE or FALSE based on whether it succeeds. `get_vm_cert` provides a stronger check, by retrieving the VM's certificate and throwing an error if this is not found. Note that you should still verify the certificate's authenticity before relying on it.
#' @return
#' For `in_azure_vm`, a boolean. For `get_vm_cert`, a PKCS-7 certificate object.
#' @export
in_azure_vm <- function()
{
    obj <- try(httr::GET(metadata_host), silent=TRUE)
    inherits(obj, "response") && httr::status_code(obj) == 400
}


#' @rdname in_azure_vm
#' @export
get_vm_cert <- function(nonce=NULL)
{
    update_attested_metadata(nonce)
    if(is.null(attested$signature))
        stop("No certificate found", call.=FALSE)

    openssl::read_p7b(openssl::base64_decode(attested$signature))[[1]]
}


.onLoad <- function(libname, pkgname)
{
    update_instance_metadata()
    update_attested_metadata()
}


