#
# Copyright (c) 2024 The Good Penguin Ltd
#
# SPDX-License-Identifier: MIT
#
# This is a basic wrapper for Scarthgap and later around oe.buildcfg

import oe.buildcfg

def get_metadata_branch(path):
    return oe.buildcfg.get_metadata_git_branch(path)

def get_metadata_revision(path):
    return oe.buildcfg.get_metadata_git_revision(path)

def get_metadata_remotes(path):
    return oe.buildcfg.get_metadata_git_remotes(path)

def get_metadata_remote_url(path, remote):
    return oe.buildcfg.get_metadata_git_remote_url(path, remote)

def get_metadata_describe(path):
    return oe.buildcfg.get_metadata_git_describe(path)

