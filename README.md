Introduction
============

This is a collaborative repository, including packages (e.g., NCL) and tools (e.g., NCL/C) to process and diagnose the climate observation and model data.

A package represents a phenomenon in atmosphere, ocean, etc., and should be developed under the standards of a uniform diagnosis **framework** (see **Framework** section).

Installation
============

It is recommendated to use `git` to obtain a copy of `geodiag` by using the following command:
```
$ git clone https://github.com/lasg-model/geodiag.git
```
After cloning, add the following line in ".bashrc" for BASH shell:
```
source <path_to_geodiag>/setup.sh
```
When `geodiag` central repository is updated, run `geodiag update` command to get the updates (only valid when you get GEODIAG through `git`).

Usage
=====

In **GEODIAG**, the calling of each package is through the calling of the main command interface as:

      $ geodiag run <package> [<options>]

where `<package>` is a suite of scripts, and `<options>` are necessary options for the running of this package if have.

There are some demostrations about the use of tools in `<path_to_geodiag>/demos`, you can try them out!

Framework
=========

Each package complies with the following directory structure:
```
<package>/
    driver.sh
    README.md
    manifest
    *.ncl or other codes
```
The `driver.sh` should provide `<package>_help` and `<package>_run` BASH functions.

| function         | purpose                       |
| ---------------- | ----------------------------- |
| `<package>_help` | print help message to user    |
| `<package>_run`  | run all the diagnosis scripts |
| `...`            | ...                           |

In `README.md` write down some key information about what does this package do and what methods are used. Also list the necessary references and who are responding to this package.

In `manifest` write down the basic information about this package so that user will get a whole picture of available packages when running `geodiag list`.

Authors
=======

- Li Dong <dongli@lasg.iap.ac.cn>

