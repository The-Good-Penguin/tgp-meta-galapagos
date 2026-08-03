#
# Copyright (c) 2026 The Good Penguin Ltd
#
# SPDX-License-Identifier: MIT
#
# Uploads the Yocto-generated license.manifest for an image to Galapagos,
# which turns it into a PDF license report and emails it out.
#
# Yocto generates license.manifest automatically for every image build, so
# no extra configuration is needed to produce the input.
#
# Uses the same product variables as galapagos-cve-check:
#   GALAPAGOS_PRODUCT_NAME     Product name shown in the report
#   GALAPAGOS_PRODUCT_KEY      Product key (must have the "license" feature)
#   GALAPAGOS_REPORT_EMAIL     Recipient email address(es), comma separated
#   GALAPAGOS_REPORT_INTERVAL  build | daily | weekly
#   GALAPAGOS_PRODUCT_TAG      Optional free-form tag
#   GALAPAGOS_RECIPE_NAME      If set, the task only runs for that recipe
#
# License-specific overrides (default to the shared values above):
#   GALAPAGOS_LICENSE_EMAIL     Recipients for license reports only
#   GALAPAGOS_LICENSE_INTERVAL  Interval for license reports only

GALAPAGOS_LICENSE_EMAIL ?= "${GALAPAGOS_REPORT_EMAIL}"
GALAPAGOS_LICENSE_INTERVAL ?= "${GALAPAGOS_REPORT_INTERVAL}"

def check_galapagos_license_recipe(d):
    recipe_name = d.getVar("GALAPAGOS_RECIPE_NAME")
    if not recipe_name:
        return True
    pn = d.getVar("PN")
    return pn == recipe_name

def find_license_manifest(d):
    import os
    license_dir = d.getVar('LICENSE_DIRECTORY')
    image_name = d.getVar('IMAGE_NAME') or ""
    image_suffix = d.getVar('IMAGE_NAME_SUFFIX') or ""
    pkgarch = d.getVar('SSTATE_PKGARCH') or ""

    candidates = [
        os.path.join(license_dir, pkgarch, image_name, 'license.manifest'),
        os.path.join(license_dir, pkgarch, image_name + image_suffix, 'license.manifest'),
        os.path.join(license_dir, image_name, 'license.manifest'),
        os.path.join(license_dir, image_name + image_suffix, 'license.manifest'),
    ]
    for candidate in candidates:
        if os.path.isfile(candidate):
            return candidate

    # Fall back to a glob for layouts not covered above
    import glob
    matches = glob.glob(os.path.join(license_dir, '**', 'license.manifest'),
                        recursive=True)
    matches = [m for m in matches if image_name in m]
    if matches:
        return sorted(matches)[-1]
    return None

python do_galapagos_license_upload () {
    import os

    if not check_galapagos_license_recipe(d):
        return

    if not d.getVar('IMAGE_NAME'):
        bb.fatal("galapagos-license-check should only be included in image builds")

    layer_dir = d.getVar('GALAPAGOS_LAYERDIR')

    manifest_path = find_license_manifest(d)
    if manifest_path is None:
        bb.error(f"license.manifest not found under {d.getVar('LICENSE_DIRECTORY')}")
        return

    product_name = d.getVar('GALAPAGOS_PRODUCT_NAME')
    product_key = d.getVar('GALAPAGOS_PRODUCT_KEY')
    email = d.getVar('GALAPAGOS_LICENSE_EMAIL')
    interval = d.getVar('GALAPAGOS_LICENSE_INTERVAL')
    product_tag = d.getVar('GALAPAGOS_PRODUCT_TAG')
    image_name = d.getVar('IMAGE_BASENAME') or d.getVar('IMAGE_NAME')

    if product_name is None:
        bb.error("Please set GALAPAGOS_PRODUCT_NAME in your local.conf")

    if product_key is None:
        bb.error("Please set GALAPAGOS_PRODUCT_KEY in your local.conf")

    if email is None:
        bb.error("Please set GALAPAGOS_REPORT_EMAIL or GALAPAGOS_LICENSE_EMAIL in your local.conf")

    if not interval in ("build", "daily", "weekly"):
        bb.error("Please set GALAPAGOS_REPORT_INTERVAL or GALAPAGOS_LICENSE_INTERVAL in your local.conf to build, daily or weekly")
        return

    if not all((product_name, product_key, email, interval)):
        return

    product_tag_args = ""
    if product_tag is not None:
        product_tag_args = f"--product_tag {product_tag}"

    try:
        bb.plain(f"Uploading license.manifest for {image_name} to Galapagos")
        bb.process.run(f"{layer_dir}/scripts/send-galapagos-license-manifest.py {manifest_path} \
                         \"{product_name}\" \"{product_key}\" \"{email}\" \"{interval}\" \
                         --image_name \"{image_name}\" \
                         {product_tag_args}")
    except bb.process.CmdError as exc:
        bb.warn(f"Failed to upload license manifest")
        return
}

addtask do_galapagos_license_upload before do_rm_work do_build after do_image_complete
do_galapagos_license_upload[network] = "1"
do_galapagos_license_upload[nostamp] = "1"
do_galapagos_license_upload[depends] += "python3-requests-native:do_populate_sysroot"
