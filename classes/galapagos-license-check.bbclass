#
# Copyright (c) 2026 The Good Penguin Ltd
#
# SPDX-License-Identifier: MIT
#
# Uploads the Yocto-generated license.manifest for an image to the
# Galapagos /license endpoint. Reuses the galapagos-cve-check product
# variables; GALAPAGOS_LICENSE_EMAIL/INTERVAL override the shared ones
# for license reports only.

GALAPAGOS_URL ?= "https://galapagos.thegoodpenguin.co.uk"
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
    import glob
    license_dir = d.getVar('LICENSE_DIRECTORY')
    image_name = d.getVar('IMAGE_NAME') or ""
    image_suffix = d.getVar('IMAGE_NAME_SUFFIX') or ""
    pkgarch = d.getVar('SSTATE_PKGARCH') or ""

    # The manifest directory layout varies between Yocto releases
    candidates = [
        os.path.join(license_dir, pkgarch, image_name, 'license.manifest'),
        os.path.join(license_dir, pkgarch, image_name + image_suffix, 'license.manifest'),
        os.path.join(license_dir, image_name, 'license.manifest'),
        os.path.join(license_dir, image_name + image_suffix, 'license.manifest'),
    ]
    for candidate in candidates:
        if os.path.isfile(candidate):
            return candidate

    matches = glob.glob(os.path.join(license_dir, '**', 'license.manifest'),
                        recursive=True)
    matches = [m for m in matches if image_name in m]
    if matches:
        return sorted(matches)[-1]
    return None

python do_galapagos_license_upload () {
    import os
    import sys

    if not check_galapagos_license_recipe(d):
        return

    if not d.getVar('IMAGE_NAME'):
        bb.fatal("galapagos-license-check should only be included in image builds")

    sys.path.append(d.getVar('GALAPAGOS_LAYERDIR') + "/lib")
    import gal_upload

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

    with open(manifest_path, "rb") as manifest_file:
        manifest_content = manifest_file.read()

    fields = {
        "product": product_name,
        "email": email,
        "interval": interval,
        "image_name": image_name,
        "product_tag": product_tag,
    }
    files = {
        "license_manifest": ("license.manifest", manifest_content),
    }

    url = d.getVar('GALAPAGOS_URL') + "/license"
    bb.plain(f"Uploading license.manifest for {image_name} to Galapagos")
    ok, message = gal_upload.upload(url, product_key, fields, files)
    if ok:
        bb.plain(f"Galapagos: {message}")
    else:
        bb.warn(message)
}

addtask do_galapagos_license_upload before do_rm_work do_build after do_image_complete
do_galapagos_license_upload[network] = "1"
do_galapagos_license_upload[nostamp] = "1"
