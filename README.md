meta-galapagos
==============

Galapagos is a CVE analysis service provided by The Good Penguin.
Artifacts from a Yocto build such as data from Yocto's cve-scan can be
uploaded to the service, in return the service will analyse the data
and email a report with recommended mitigation steps.

The meta-galapagos layer provides a means of integrating this service into
your Yocto build.

Galapagos supports all versions of Yocto after Dunfell commit
dcd40cfa375c272eda1ccc3063a48c5ec0a50ab5.

Galapagos requires meta-python and meta-oe layers.

The layer can be added as follows:

    bitbake-layers add-layer meta-galapagos

Please update your local.conf to include the following:

    INHERIT += "cve-check"
    INHERIT += "galapagos-cve-check"

Set GALAPAGOS_RECIPE_NAME to the name of the your main image recipe, eg:

    GALAPAGOS_RECIPE_NAME = "core-image-sato"

If you have additional packages that are not included in the image you
are building, for example a kernel or bootloader installed elsewhere,
you can add them to the GALAPAGOS_EXTRA_PACKAGES variable:

    GALAPAGOS_EXTRA_PACKAGES = "linux-yocto u-boot"

The following variables must also be included, please note that the
values below are examples and should be changed to meet your needs.

    GALAPAGOS_PRODUCT_NAME="Penguin Feeder X12"
    GALAPAGOS_PRODUCT_KEY="Fd3cPzYEAT5JftYR"
    GALAPAGOS_REPORT_EMAIL="amurray@thegoodpenguin.co.uk,additional@emails.co.uk"
    GALAPAGOS_REPORT_INTERVAL="daily"
    GALAPAGOS_CVE_SEVERITY_THRESHOLD="3.0" # Optional
    GALAPAGOS_IGNORED_ATTACK_VECTORS="LOCAL,PHYSICAL" # Optional

Each time you build an image with Yocto a cve-scan will be performed and
the output uploaded to Galapagos. A report will be emailed to the address
in GALAPAGOS_REPORT_EMAIL. The GALAPAGOS_PRODUCT_NAME variable is used to
provide a friendly name for your product/image. The GALAPAGOS_PRODUCT_KEY
uniquely identifies your product to the Galapagos server, please request
a key by emailing sales@thegoodpenguin.co.uk.

The GALAPAGOS_REPORT_INTERVAL variable is used to describe how frequently
the service will send report emails. The available values are:

    "build"  - a report is sent for every build
    "daily"  - a report is sent no more than once a day
    "weekly" - a report is sent no more than once a week

For the "daily" and "weekly" values, a report is still triggered on a build
but the report is only sent if there hasn't been any reports sent in the past
day or week. Thus the email report will always represent the most recent
build.

The `GALAPAGOS_CVE_SEVERITY_THRESHOLD` is an optional parameter, which allows you to ignore 
CVEs that are below a set severity threshold. Valid values are `0.0` to `10.0`

The `GALAPAGOS_IGNORED_ATTACK_VECTORS` is an optional parameter. This allows you to ignore
CVEs where their attack vector matches one provided. Multiple attack vectors can be used
by deliminating them with a comma (,). Valid options are `PHYSICAL`, `LOCAL`, 
`ADJACENT_NETWORK` and `NETWORK`.

Please note that no specific target is needed, the report will be generated
upon the completion of a build of any image (e.g. core-image-minimal).

Maintenance
===========

Send pull requests, patches, comments or questions to mbullock@thegoodpenguin.co.uk
GitHub pull requests are also welcome.

Maintainers: Matthew Bullock <mbullock@thegoodpenguin.co.uk>

