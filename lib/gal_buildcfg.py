#
# Copyright (c) 2024 The Good Penguin Ltd
#
# SPDX-License-Identifier: MIT
#
# This is a basic wrapper for Scarthgap and later around oe.buildcfg

buildcfg_available = True
try:
    import oe.buildcfg
except ModuleNotFoundError:
    buildcfg_available = False

def get_metadata_branch(path):
    if buildcfg_available:
        return oe.buildcfg.get_metadata_git_branch(path)
    else:
        try:
            rev, _ = bb.process.run('git rev-parse --abbrev-ref HEAD', cwd=path)
        except bb.process.ExecutionError:
            rev = '<unknown>'
        return rev.strip()

def get_metadata_revision(path):
    if buildcfg_available:
        return oe.buildcfg.get_metadata_git_revision(path)
    else:
        try:
            rev, _ = bb.process.run('git rev-parse HEAD', cwd=path)
        except bb.process.ExecutionError:
            rev = '<unknown>'
        return rev.strip()

def get_metadata_remotes(path):
    if buildcfg_available:
        return oe.buildcfg.get_metadata_git_remotes(path)
    else:
        try:
            remotes_list, _ = bb.process.run('git remote', cwd=path)
            remotes = remotes_list.split()
        except bb.process.ExecutionError:
            remotes = []
        return remotes

def get_metadata_remote_url(path, remote):
    if buildcfg_available:
        return oe.buildcfg.get_metadata_git_remote_url(path, remote)
    else:
        try:
            uri, _ = bb.process.run('git remote get-url {remote}'.format(remote=remote), cwd=path)
        except bb.process.ExecutionError:
            return ""
        return uri.strip()

def get_metadata_describe(path):
    if buildcfg_available:
        return oe.buildcfg.get_metadata_git_describe(path)
    else:
        try:
            describe, _ = bb.process.run('git describe --tags', cwd=path)
        except bb.process.ExecutionError:
            return ""
        return describe.strip()

