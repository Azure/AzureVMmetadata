host <- httr::parse_url("http://169.254.169.254")
inst_api_version <- "2019-02-01"
att_api_version <- "2018-10-01"
ev_api_version <- "2017-11-01"


#' @export
instance <- new.env()

#' @export
attested <- new.env()

#' @export
events <- new.env()


#' @export
update_instance_metadata <- function()
{
    host$path <- "metadata/instance"
    host$query <- list(`api-version`=att_api_version)
    res <- try(httr::GET(host, httr::add_headers(metadata=TRUE)), silent=TRUE)

    if(!inherits(res, "response") || res$status_code > 299)
        return(NULL)

    inst <- httr::content(res)
    for(x in names(inst))
        instance[[x]] <- inst[[x]]
    invisible(inst)
}


#' @export
update_attested_metadata <- function(nonce=NULL)
{
    host$path <- "metadata/attested/document"
    host$query <- list(`api-version`=att_api_version)
    res <- try(httr::GET(host, httr::add_headers(metadata=TRUE, nonce=nonce)), silent=TRUE)

    if(!inherits(res, "response") || res$status_code > 299)
        return(NULL)

    att <- httr::content(res)
    for(x in names(att))
        attested[[x]] <- att[[x]]
    invisible(att)
}


#' @export
update_scheduled_events <- function()
{
    host$path <- "metadata/scheduledevents"
    host$query <- list(`api-version`=ev_api_version)
    res <- try(httr::GET(host, httr::add_headers(metadata=TRUE)), silent=TRUE)

    if(!inherits(res, "response") || res$status_code > 299)
        return(NULL)

    ev <- httr::content(res)
    for(x in names(ev))
        events[[x]] <- ev[[x]]
    invisible(ev)
}



#' @export
get_vm_cert <- function()
{
    if(is.null(attested$signature))
        return(NULL)

    openssl::read_p7b(openssl::base64_decode(attested$signature))[[1]]
}


#' @export
in_azure_vm <- function()
{
    obj <- try(httr::GET(host), silent=TRUE)
    inherits(obj, "response") && httr::status_code(obj) == 400
}


.onLoad <- function(libname, pkgname)
{
    update_instance_metadata()
    update_attested_metadata()
}

