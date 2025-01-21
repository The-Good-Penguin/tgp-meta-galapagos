#
# Copyright (c) 2024 The Good Penguin Ltd
#
# SPDX-License-Identifier: MIT
#
# These are re-implemented to match the way Scarthgap does things
# Only handles git currently
import os
import subprocess
import bb.process

def get_metadata_branch(path):
    try:
        rev, _ = bb.process.run('git rev-parse --abbrev-ref HEAD', cwd=path)
    except bb.process.ExecutionError:
        rev = '<unknown>'
    return rev.strip()

def get_metadata_revision(path):
    try:
        rev, _ = bb.process.run('git rev-parse HEAD', cwd=path)
    except bb.process.ExecutionError:
        rev = '<unknown>'
    return rev.strip()

def get_metadata_remotes(path):
    try:
        remotes_list, _ = bb.process.run('git remote', cwd=path)
        remotes = remotes_list.split()
    except bb.process.ExecutionError:
        remotes = []
    return remotes

def get_metadata_remote_url(path, remote):
    try:
        uri, _ = bb.process.run('git remote get-url {remote}'.format(remote=remote), cwd=path)
    except bb.process.ExecutionError:
        return ""
    return uri.strip()

def get_metadata_describe(path):
    try:
        describe, _ = bb.process.run('git describe --tags', cwd=path)
    except bb.process.ExecutionError:
        return ""
    return describe.strip()

